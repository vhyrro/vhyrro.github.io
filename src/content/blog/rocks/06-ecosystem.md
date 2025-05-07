---
title: "Lux Devlog #006"
description: "Building out Lua's project ecosystem"
pubDatetime: 2025-05-07
tags:
  - rocks
  - lux
draft: false
slug: "rocks-devlog-06"
---

In the previous devlog, we made a large leap forward by adding `lux.toml` support to Lua codebases.
It's time we make it even better.

## `lx pack`

Before we get to all that, Marc spent some time to implement `lx pack`! To summarize, packed rocks are special Lua packages
that contain precompiled symbols for a single operating system (known as the target).

This lets users download a prebuilt package, instead of having to compile
everything themselves. `lx pack` allows you to perform this precompilation.

## `lx add`

Since we now use a TOML file for storing project dependencies, we can easily alter that TOML file in a predictable manner.
This paves way for a slew of new quality-of-life features, and the first one I implemented is `lx add`.

As the name suggests, the command adds a new dependency to the current project, automatically downloading the package to the local
Lux tree. You can also specify a version of your choosing: `lx add neorg 7.0.0`. Lua has finally entered the 2000s!

## `extra.rockspec`

Not everyone may want to migrate (nor use) the TOML system for describing a project. For this reason, I'd had liked Lux to
support a rockspec file alongside the TOML file (similar to the old `project.rockspec` format).

This has finally been implemented! By creating a file called `extra.rockspec` in the project root, you will instruct Lux
to merge the TOML and the rockspec together when performing any sort of operation.

Note, however, that the merging is not deep, i.e. the rockspec takes complete
precedence over the `lux.toml` file. Specifying dependencies in both the TOML
and the rockspec will result in only the rockspec's dependencies being used.

## Further Compatibility

We're constantly striving for higher compatibility with `luarocks.org`, and so
Marc implemented a long awaited feature - dev manifests. These allow you to download
Lua packages without a versioning scheme (instead just downloading the latest available revision of the project).

There are plenty of dev-only packages out there, so this should increase our compatibility rate severalfold :)

## What's next?

We've been making plenty of progress recently, so, what's next?

It's time to implement even deeper integrations with projects - for instance, I want to make `lx lua` supply project-related
variables directly to the Lua interpreter - things like paths to project dependencies and project-local binaries.

I'm also pretty sure that, during the last two major refactors, I messed up a part of `lx check`. That'll also be worth looking at
hah.

See you on the flipside!
