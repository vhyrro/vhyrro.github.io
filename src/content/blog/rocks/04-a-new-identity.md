---
title: "Lux Devlog #004"
description: "A new identity!"
pubDatetime: 2025-04-21
tags:
  - rocks
  - lux
draft: false
slug: "rocks-devlog-04"
---

Hello, world! It's been a while since I last made a blog post. In the next set of blog posts, I'll hope to catch you entirely up to speed with `rocks`'s development cycle.
Speaking of which, `rocks` is no longer called `rocks`. And we have a new mascot!

![our new mascot](@assets/images/lux-logo.svg)

The upcoming posts will be written in retrospect, meaning that most of the features are done already, but I'm pacing the devlogs as if they were happening in realtime.
It should make for a much more pleasant reading experience for future readers!

## A new Identity

In order to prevent confusion, we've decided to rename `rocks` to Lux! Instead of running `rocks [...]` commands in your terminal, you will now be running `lx [...]` commands instead :)

From here on, I will call the project Lux, and will not refer to the old name. The older blog posts, as well as the URLs for these posts, will still use the name `rocks` for backwards compatibility, so
others' links on the web don't break.

## `lx check`

We've added a new command for ensuring your Lua code is clean and correct. `lx check` downloads the latest version of `luacheck` and runs it on your codebase, printing out any warnings or errors.
Feel free to also set up a Git hook to run this code on every commit, [see how here](https://nvim-neorocks.github.io/guides/formatting-linting)!

## Project Lockfiles

We spent a while trying to figure out the most effective strategy to implement these. Lux now supports lockfiles for projects, as opposed to just lockfiles for rocktrees.

You'll be able to see it
as a `lux.lock` in your project directories! These are simple JSON files which describe the current state of all dependencies in your project, making your environment fully reproducible across various systems.

## `lx uninstall` / `lx doc`

In our hunt to reimplement all the major functionality from `luarocks`, we've implemented the `uninstall` and `doc` commands. Uninstall is different to `lx remove`, since `lx remove` removes dependencies of the current
project, whereas `lx uninstall` operates on the global rocktree.

`lx doc` is a fancy way of displaying documentation for any rock out there, feel free to try it out.

## Leftover Binaries

I've finally fixed a long-standing issue related to installed Lua binaries. As you may or may not know, packages on `luarocks.org` can ship their own binaries. We have supported this for a while now,
but we never associated the binaries with the rock that produced it.
This meant that uninstalling a rock never uninstalled its binary, since we had no way of tracking it.

Now, we implemented a new `binaries` field into the lockfile, which tracks what rock produces which binaries. Upon removal of a rock, the binary will now also be yeeted :)

## Big Things Ahead

Next up, I'd like to work on an incredibly bold and big feature. Currently, we support a `project.rockspec` file as the default Lux project file. However, rockspec files are very unwieldy and impossible
to modify properly because of the turing completeness of Lua.

Instead, I'd like to migrate us to a new `lux.toml` file, which will supercede `project.rockspec` in hopes of making things much simpler
for the average user. TOML is easy to read and write, and also to remember.

This will be a big shift in what command we'll be able to implement in the future, exciting things ahead!
