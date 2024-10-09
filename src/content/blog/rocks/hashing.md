---
title: "Rocks Devlog #002"
description: "How your packages never break."
pubDatetime: 2024-11-04
tags:
  - rocks
draft: false
slug: "rocks-devlog-02"
---

# Rocks Devlog #2

Welcome to the second devlog in the series! In this one, we'll discuss how `rocks` ensures that your dependencies and plugins never get ovewritten.

If you thought "do something similar to the nix store", you'd be absolutely right.

## The Problem

First, let's quickly break down what problems we're trying to solve as a package manager for Lua. Our job is to take
a rock (the name for a package in Lua land), unpack it, put the Lua files in the correct place and ensure all dependencies are installed. As will be evident soon,
managing these dependencies is not an easy feat.

In `rocks`, packages are installed in something called a rock tree. This tree contains a lockfile, which describes which packages
are installed and how they all relate with one another. The tree also contains a `rocks/` directory - it's here that all Lua files are unpacked so that they can be used in
your scripts. There are three types of rock trees - those that are created for each Lua project (which hold local packages like
dependencies for a given project), those that are installed for the current user (for things like local binaries or helper rocks)
and those that are system-wide.

A rock tree is structured as follows:
- `/rocks/<lua-version>` - contains rocks for a given Lua version
- `/rocks/<lua-version>/<rock>/etc` - documentation and supplementary files for the rock
- `/rocks/<lua-version>/<rock>/lib` - shared libraries (.so files)
- `/rocks/<lua-version>/<rock>/src` - actual code of the rock
- `/bin` - binary files produced by various rocks

`<lua-version>` can be any of `5.1`, `5.2`, `5.3`, `5.4` - simple! Here's a question that might throw you for a loop - what
should `<rock>` be? Should it just be the name and version of the rock: `/rocks/5.1/my-package@1.0.0/...`? As we're
about to find out, it's much, *much* more complicated.

Let's consider the following case: `rock1` is already installed in the user-wide rock tree. `rock1` relies on a hypothetical rock called
`dependency`, whose latest version is `1.2.0`.
The rockspec for `rock1` states that it permits `dependency < 1.0.0`, meaning any version of `dependency` prior
to `1.0.0`. The most recent version of `dependency` prior to `1.0.0` is `0.9.0`, so that's what's installed in the
rock tree at this point. Got that?

Now, let's say we run `rocks install rock2`. `rock2` *also* relies on `dependency`, but it specifies that
it expects `dependency >= 1.0.0`, which is a completely different constraint to what `rock1` wanted.
With the aforementioned system, this is no problem: we'll have two directories, `dependency@0.9.0/`
and `dependency@1.2.0/` installed separately, easy!

Now, consider a more complicated case: imagine that we install `rock3`, which relies on `dependency <= 1.0.0`,
and that `dependency` is shared between `rock1` and `rock3`. If you're lost already, let me reiterate. `rock1`
requires `dependency < 1.0.0`, whereas `rock3` requires `dependency <= 1.0.0`. Imagine that both of these rocks
share the same installation of `dependency@0.9.0/` - this is fine because the version `0.9.0` satisfies both
`< 1.0.0` as well as `<= 1.0.0`.

Why am I blabbing on about this? Imagine an unsuspecting person (you) now runs `rocks update`, which updates all
packages to their latest possible releases. Can you see the problem? `rock3` will want to update `dependency@0.9.0`
to `1.0.0`, because that's the latest available version that satisfies `<= 1.0.0`,
but `rock1` expects `< 1.0.0`, which **does not include** `1.0.0`. We have a conflict! Two rocks want two different
versions of a *shared dependency*. Yikes. We'll need a better system.

But wait, you thought I was done frying your brain?? Reconsider. `rocks` also permits doing something special - it allows
you to **pin** packages. A pinned package's version should never, ever change. Consider *this*:
- `rock1` requires `< 1.0.0`
- `rock3` requires `<= 1.0.0`
- The user runs `rocks pin dependency@0.9.0`, freezing the dependency.

Upon running `rocks update`, we have a three-sided clash: `rock3` wants to upgrade `dependency@0.9.0` to `1.0.0`, `rock1` will
want to keep it the same, *and* because the package is pinned it will also be unable to move.

I'll leave it up to your imagination to figure out even more complicated version conflicts like this.

---

> Just don't update the package then, simple.
> - You (probably)

That is a solution, and it's one that `luarocks` has used. There's something that isn't talked about enough though: users
do incredibly, incredibly silly things. Sometimes they will find an unholy combination of invocations that completely
messes up their rock tree state. In this "dependencies can be shared" implementation, it's not a matter of if something will
mess up, but *when*. Maybe they somehow *do* update the dependency on accident, rendering `rock1` completely broken.
Maybe `rock3` **doesn't work** with versions prior to `1.0.0`, and the developer mistakenly said they support everything
prior to `1.0.0`. There are too many things that can go wrong!

## Hashes, my Beloved

After a few drafts of how we could solve these problems in `rocks`,
we somehow ended up reinventing/reimplementing a similar system to the Nix store. Here's what we did:
- Instead of storing a rock in a `name@version/` directory, we've instead resorted to a `<hash>-<name>@<version>/` directory.
  The "short hash", as I've called it, is built up of the name, version, pin state and constraint (e.g. `< 1.0.0`). Any difference in any of these variables
  will result in a completely different hash.
- The package is uniquely identifiable in the lockfile by this hash - this leaves no ambiguity. A pinned package is different
  to an unpinned package; a constrained package is different to an unconstrained one, and so on.

Let's imagine the super complicated situation that I presented at the end of the last section:
- `rock1` wants `dependency < 1.0.0`
- `rock3` wants `dependency <= 1.0.0`
- `dependency` is pinned

With this system, each iteration of `dependency` will have a different hash (the first two have different constraints, and the third has a different pin state), and as such we will have **3 different installations**
of `dependency` in our rock tree, completely independent of one another. Any of them can be individually updated and no clashes
can possibly occur between them.

What's unique about this system is that dependencies still can be shared! Two different rocks *can* share the same version
of `dependency`, provided that the hash is exactly the same. In those cases, we can guarantee that absolutely nothing can go wrong,
no matter how much you try to muck about.

This is almost the exact same solution that Nix uses - all packages and dependencies are prefixed with a hash, except that in Nix's
case it creates a mega hash from all information about the package, including the hash of its sources. We don't do this, because
we'd have no way of actually *finding* the rock in the filesystem. If a user went "please delete `rock1`", how would we know
the name of the directory we should delete? We don't have access to all the sources ahead of time, or at the very least that'd
be stupidly inefficient.

## Conclusion

Now you know! If there's anything you should learn from this post, it's this short rhyme: hashes are a great way of preventing clashes.
Dependencies are a complicated thing, but with a little cheekiness, we can eliminate almost all their issues entirely.
If you have any extra questions, feel free to shoot me an email!
