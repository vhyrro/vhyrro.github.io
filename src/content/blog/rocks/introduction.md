---
title: "Rocks Devlog #001"
description: "A better package manager for Lua."
pubDatetime: 2024-11-02
tags:
  - rocks
draft: false
slug: "rocks-devlog-01"
---

# A New Moon

Hello and welcome to a series of devlogs about [`rocks`](http://github.com/nvim-neorocks/rocks), a modern package manager for Lua which [Marc Jakobi](http://github.com/mrcjkb) and I have
been working on over the past few months.

In this first post, I'd like to lay out the rationale and progress made thus far. In the next post, we'll delve into some meaty technical
challenges we faced along the way!

# Rationale

Ironically, the motivation for creating a new package manager for Lua stemmed
from Neovim, of all places. Marc and I are the developers of
[`rocks.nvim`](https://github.com/nvim-neorocks/rocks.nvim), a better approach
to managing plugins for the world's most loved text editor (according to
stackoverflow, at least). To do this, we've been using `luarocks` as the backing package
manager for installing and managing plugins packaged as rocks. This has many advantages, most
importantly proper dependency resolution and all of the rigor that you get from
a fully fledged package manager.

After a few months of using `luarocks`, we started to encounter a few problems with the package manager deep down in its implementation.
No worries, though, we're happy to fulfill our due diligence as open source developers - we made issues to help track all of the problems
down and they were resolved swiftly, lovely!

There are so many problems you can solve by contributing to your favourite FOSS project, you should try it someday! But, it's not all sunshine
and rainbows. After a lot of digging in the core of luarocks, we began noticing things that are simply not fixable with a pull request:
- Luarocks is purely a binary and has no library component, meaning it cannot be embedded in other programs. The whole program is written in Lua,
  meaning that even if we *did* implement a library component, it's still not embeddable in a compiled program.
- Luarocks uses existing lua headers on the system when trying to compile rocks - this has caused us a myriad of headaches for us in the past.
  Users usually aren't savvy enough to know how to install their own Lua headers (for a specific target version) and it's impossible for us, as developers,
  to ensure that the appropriate Lua installation is present on the target system.
- Luarocks installs everything to a global rocktree by default, and never tries to infer the Lua version it should use, requiring that you always
  supply it as an option flag. From our experience, these two things are singlehandedly the biggest sources of frustration for regular users.
- To top it all off, there is no notion of a "project" in lua. It's just a conglomeration of code with a rockspec, which provides instructions
  on how to make sense of all the loosely coupled code files that you have. If you want to publish a new version of your code, you have to write a new rockspec
  with altered metadata. The rockspec's name must also contain the version string *in the filename*: trying to publish a `rock-1.0.0.rockspec` with
  a `version = "1.0.2"` in the file will cause an error. Excluding a version (i.e. `rocks.rockspec`) will also error.
- While we were preparing various pull requests (e.g. annotating the entire codebase's types with [LuaCATS](https://luals.github.io/wiki/annotations/), writing
  improvements to luarocks's hash checks so Nix support can work properly), it was
  brought to our attention that the entirety of luarocks is undergoing a [rewrite to Teal](https://github.com/luarocks/luarocks/pull/1705).
  This messed us up a little: Teal is a niche language. It has a type system, sure, but the type checker [isn't even as good as LuaCATS](https://github.com/luarocks/luarocks/issues/1530#issuecomment-1971669545), therefore
  fixing nothing about the aforementioned problems above.

  If we're going this far - rewriting the whole codebase - couldn't we do it in something more serious, start over, and fix all of the problems right out the gate?
  We're not here to judge or dictate how a project is supposed to be written, don't mistake us for one of those people, but we looked at the problem
  logically and emotionlessly: if we disagree with the general direction, can we do *better*?


Conveniently enough, we've been working on a Rust port of `luarocks` prior to this already, but our goal was different at the time.
We wanted to create a truly embeddable library port, meaning that one could embed something that behaves exactly like luarocks in their own
program. We decided to further repurpose this into a full reimplementation, and this is where we are today!

# Hello, `rocks`!

As of writing this post, in just a few months of actual development time, we've successfully implemented **80%** of luarocks's existing functionality!
You can safely use `rocks` for basic tasks, although I would seriously wait until our `1.0` release before you use it for anything serious - we're
fleshing out a lot of the user experience.

What's so fresh and new with our rewrite? We:
- Have a much more ergonomic CLI (loosely mirroring Cargo and Zig's CLIs)
- Install to a local rocktree by default
- Have first class support for Lua projects (with a single source-of-truth `project.rockspec` file)
- Have a full lockfile implementation with proper hashing, allowing Nix integration to be much more seamless
- Automatically infer the lua version to use for a given rock
- Have builtin support for stylua with `rocks fmt`
- Full constraint and pinning support, so dependencies never get tangled
- Cache as much as we can for speed!

Things we have left to do before our `1.0.0` release:
- `rocks.loader` support, so that dependencies can be resolved directly in Lua code
- Support for more rockspec build types
- Better error messages

We hope that you're as excited as we are! Lua is a very barebones language by design, and so a complete and unbreakable package manager is
crucial so that users can layer on functionality they need at any time. In the coming posts, I hope to expand on each of the features
of our rewrite, discussing how and why our implementation is saner and simpler. See you on the flipside!
