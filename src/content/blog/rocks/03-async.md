---
title: "Rocks Devlog #003"
description: "Welcome, Mr. 4x speedup!"
pubDatetime: 2024-11-26
tags:
  - rocks
draft: false
slug: "rocks-devlog-03"
---

# Rocks Devlog #3

It's been a while (about a month) since the last update post! For those out of the loop, `rocks` is a rewrite of `luarocks` in an attempt
to vastly improve the Lua ecosystem. A lot has happened since the last update, so let's break down all the new stuff.

## Soundness Check

We've squashed many bugs related to the installation of C + Lua libraries, most notably the incorrect installation of `lib.c` modules.
We also caught a bug where the `--lua-version` passed to `rocks` would not be respected whenever the rockspec of the thing you're
installing had a different target version. The rockspec shouldn't dictate what Lua version to use, you should!

We've also fixed some issues with platform overrides, a feature of rockspecs which allow you to modify aspects of the rockspec
based on the operating system that the rock is being installed to. We'll soon be writing a compatibility test, seeing what
percentage of packages on `luarocks.org` we currently support!

## I've Hacked into Their Mainframe

This month sees the full implementation of `rocks upload`! This one was quite the challenge, mostly due to potential security flaws.
`luarocks.org` expects to receive the API key in the URL of the request... yikes. If you didn't flinch there, take my word for it,
that's not secure **at all**. It's like this by design though, so what can you do, *shrug*.

To prevent any API key leakages, we've taken care to make sure that all connections to `luarocks.org` are forced to use HTTPS.
In the code, the API key is stored in a sealed struct with no way to access the underlying API key string without using `unsafe`.
Instead of passing the key as a flag, like you do in `luarocks` (`luarocks upload --api-key <KEY>`), we force you to supply
the key under `$ROCKS_API_KEY` instead.
While all this can't possibly prevent man-in-the-middle attacks that intercept your URL and grab your API key, it's as much as we can do!

`rocks upload` is much more convenient than its counterpart, partly because it directly interfaces with projects. You don't need 20
rockspecs lying around in a directory somewhere, just run `rocks upload` and it works™!

## CLI - Comfy Luarocks Interface

We've changed the signature of `rocks install`. Previously, it was `rocks install package version`. Now, you can supply multiple
packages to install in a single invocation: `rocks install package@0.2.3 other-package@0.1.0`. You can even use version constraints:
`rocks install mypackage>=0.2.0`!

As for other CLI changes, we've implemented two massive features: `rocks test`, which automatically runs `busted` on your code, and
`rocks run`, letting you run any binary you installed from `luarocks.org` without needing to add it to your `$PATH`!

For easy debugging, we've also provided a `rocks lua` command, which runs `lua` with its version and paths automatically configured.

## The Elephant(s) in the Room

The end of this month marks the coolest feature thus far - parallel installs! `rocks` now installs dependencies as well as multiple
packages on separate threads, making everything work asynchronously. This system is possible because of our hashing system, described
in the previous blog post.

Because every rock evaluates to some sort of short hash, we can grab all
dependencies of a package ahead of time, remove any duplicate hashes (since
they'll all evaluate to the exact same package) and run all operations concurrently!
This ensures that we'll never have data races between rocks, since they all have different hashes, meaning they'll all output to different
directories.

Let's provide some numbers: `busted` is our current stress test package when it comes to testing how well our code works.
In `luarocks`'s case, it needs `22.3` seconds to fully installed `busted`. `rocks` needs... wait for it... `5.6` seconds!

That's a substantial increase in speed. You may be asking where our bottleneck is - most of these 5 seconds is actually spent waiting
for network operations to complete (responses from `luarocks.org`, cloning from `git`). We plan to take this time down to roughly 2 or 3
seconds by rewriting our manifest caching to be much more efficient.

## Conclusion

This month has seen a lot of great work on `rocks`. We plan to have a functional `1.0` release by Christmas, let's see if we can pull it off.
We're currently focusing on bug squashing and `Lua` interoperability, allowing `rocks` to be embedded directly in Lua scripts.

To the ~~lua~~ moon! 🚀
