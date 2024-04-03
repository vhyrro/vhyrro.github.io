---
title: "Just Use Semantic Versioning"
description: "Stop taking versioning so seriously."
pubDatetime: 2024-04-21
tags:
  - misc
draft: false
slug: "versioning"
---

Stop taking versioning so seriously. Seriously!

## Introduction

This post belongs to the rant-ish category, but it's
something that I think is not only prevalent throughout the programming
community but is also actively slowing it down, hence the discussion.

This post is partly inspired by my own mistakes when developing
[Neorg](https://github.com/nvim-neorg/neorg) and let me tell you --
once you notice your own mistake, you see it everywhere else. Another
source of inspiration is the half-broken state the Neovim community is in
right now stability-wise.

## Versions are <u>Critical Infrastructure</u>

Allow me to repeat - versions are <u>critical infrastructure</u>.
They're not something you slap onto your project for the jokes.

Versions are a more human-readable hash. They declare how far the
project is into its development and quantify the size and impact of
each sequential/meaningful change. Thus it is best if the version
contains as much information within itself as possible.

The perfect[^1] version format should distinguish small changes from large ones,
and meaningless changes from meaningful ones.

This information is critical to all consumers of your software -
both users and developers alike. Users gain from this information as
they know when the software they use has had a breakage, a feature release
or a bug fix - it permits them to use a specific version of that software
where they can guarantee their configurations and existing files will continue to work.

Such information is equally critical to developers. A developer
knows that once your software's version changes in a specific way
(e.g. signifying a breaking change) they should refrain from using
that new version if they want to maintain compatibility in their
project.

## Why the Fuss?

> Okay, if versioning is so critical, then people are surely all just using it?
> You said not to take versioning seriously in the beginning, and yet here you
> are taking it the most seriously out of all of us.

The fuss is about others treating versioning like a religion instead
of like a tool. Rather than being something you set and forget,
finding "the correct way" of versioning is something people search
for like some sort of holy grail.

Below are the most common fallacies I could enumerate.

### A Version is *not* a Number

A version is in fact not a number, just like explained above, it's an easier to read hash.
A single number is nowhere near enough information to distinguish the impact of changes
from their size.

Take the simple versioning scheme of starting from `0.1` and constantly adding `+0.1`
on every meaningful change: `0.2`, `0.3` etc. Not only is there no ruleset that states
"this is when you should increase the version number", there is no way to distinguish that
version bump from a breaking change, a feature fix or a bug fix.
It's just a random number that goes up every now and again.

Also no, a version exceeding the number 9 is not heresy, because versions are.
not. numbers. `10.23.2` is a valid version number, so is `100.3.0`, so is
`0.1.0`. Bumping your software version from `0.6.9` to `0.7.0` just because in
your mind `0.6.10` is "impossible" is... weird, to say the least, and goes
against meaningful (semantic) versioning methodologies.

### `1.0` is not Special

Versioning schemes like ZeroVer never allow a project to hit a `1.0`
release, as if the number `1` immediately devoids your project of
all possibilities and autonomy, throwing it into the corporate
hellscape of "versioning your breaking changes". God forbid you
ever hit the number `2`, as that's equivalent to rewriting your
project from scratch.

`1.0` should not in any way mark your project as "complete". I have noticed
that projects with this mindset have severe difficulties stabilizing their
features, as stabilizing a feature generally means stabilizing the entire
project. If they just bump the version to the next release (e.g. `0.9`), that
gives users no information about what changed - was there a big breaking change
or not? Was something stabilized or not?

Why should `1.0` determine a "stable release" of your project? You have an
infinite number line to work with! Make `1069.0.0` your "stable release" for
all anyone cares, just let your users know in your Github release or patch
notes. Don't let a single digit stop you.

### You *must* Differentiate Changes

Bugs can occur anywhere: when you add a feature or when you fix a bug and
introduce a new one as a result. For this reason you need *at least* three
numbers for your version: the breaking change counter, the feature release
counter and the bug fix counter. Whenever something in your code is a breaking
change, bump that number. Whenever you add a feature or change some code in a
backwards-compatible way, bump that. Same goes for bugs or minor patches. An
example is `1.4.12`.

This way users know when something breaks (by looking at the breaking change
counter). It also allows them to easily backtrack to an earlier version if you
introduce some massive bug into your software accidentally in e.g. a feature
release (which you eventually will, happens to us all).

## Semantic Versioning

This is the idea behind [semantic versioning](https://semver.org).
SemVer is not some sort of holy grail, but it's precisely what I said in the beginning
of this post, it's a *set and forget* system. Add something like [release-please](https://github.com/googleapis/release-please)
to your repository and never think about it again[^2].

Semantic versioning (usually) starts off at version `0.1.0`. The first number increments
on every breaking change, the second one increments on every
backwards-compatible change or feature, and the third one increments on every
chore or bugfix. Every number is incremented on its own whenever necessary.

I stated that Neovim's ecosystem has been an inspiration for this post.
Neovim itself suffers from ZeroVer, and it shows for plugin developers.

When the Neovim developers work on different aspects of the codebase, they
bundle bug fixes, features and breaking changes in one massive basket. This
creates an unstoppable loop - people use the prerelease (nightly) versions of
Neovim for its features and bug fixes, but those same nightly versions also
contain breaking changes that destroy most plugins that rely on internal APIs.
Thus the plugin developers are given a dilemma - support the latest nightly
version *only*, or keep the plugin broken on nightly versions (without having
the bug fixes and features of the nightly release)?

Furthermore, critical plugins like [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
also do not use semver, choosing to reflect Neovim's versioning scheme. This also leads to terrible
adoption of breaking changes by the community, and is a kick to the backside for users who decide to stay
on the stable release of `nvim-treesitter`, reintroducing the unstoppable loop of plugin developers supporting
the latest unstable release instead of the latest stable release.

My plugin was also a victim of this vicious cycle for over **2 years**. I can't stress how much has changed
ever since our migration to semver.

## Conclusion

When working on Neorg I was also incredibly hesitant to add semver. I believed it was impossible to version something as vast as Neorg.
One member of the community won me over with his arguments, and since then Neorg has been flourishing. I'm not afraid of change when
developing my software, as breaking the project for the better good is not scary whatsoever - if users find the change too drastic they're
free to stay on the previous stable release until they're ready. There's no dependency hell, there's no compatibility issues, no vicious cycles.
Life good. Grug happy.

Let's make everyone's lives good. Proper versioning positively trickles down the dependency chain.

If you find yourself stuck when developing a project because any change you
make will lead to devastation, swiftly check if a decent versioning scheme
won't help alleviate the issues. Setting one up with release-please takes
upwards of 10 minutes!

As always, hope you have a lovely day.

---

[^1]: Obviously there is nothing in the software space that's perfect.
      I'm referring to "as good as possible" here.
[^2]: You get to choose whenever a new version should be published, but that new version
      will be in accordance with semver. See the [release-please github action docs](https://github.com/google-github-actions/release-please-action?tab=readme-ov-file#how-release-please-works) for more on that.
