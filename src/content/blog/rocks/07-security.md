---
title: "Lux v0.26.0"
description: "Lux now sandboxes untrusted Lua scripts."
pubDatetime: 2026-03-12
tags:
  - rocks
  - lux
draft: false
slug: "lux-update-07"
---

![The Lux logo](@assets/images/lux-logo.png)

It has been several months since the last blog post! There have been many, many important changes made to Lux over the year.
However, just recently, we've perhaps implemented the most important feature of all.

We have spent the last two weeks working on integrating
[piccolo](https://github.com/kyren/piccolo) into Lux as our VM for executing
untrusted Lua scripts. Thousands of changes, hours of debugging. Today the PR
was merged! 🎉🎉

With constant attacks on NPM and other popular package managers, security is
becoming more vital every day. From now on, all rockspecs and manifests passed to Lux are
placed in a strong sandbox, guarded from malicious bytecode, filesystem/network
access, DoS attacks, evil dynamic libraries and more.

## How?

**Sandboxing Lua is very complicated**. You can't simply take a regular Lua interpreter and remove access to critical libraries.
Even if you delete access to libraries like FFI or shell execution, users can still use crazy techniques like bytecode sideloading or
custom metatables to completely bend the fabric of spacetime and still get code execution.

For this reason we needed a very drastic solution. Piccolo is a stackless Lua
VM with builtin security features in mind. It's designed from
the ground up in Rust with a completely bespoke architecture centered around
sandboxing. It allows us to control execution time of programs and it also
features a specialized garbage collector built for safety.

Even though piccolo is experimental, we ran multiple tests and extended its standard library with our own fork: [ottavino](https://github.com/lumen-oss/ottavino).
With this at the ready we completely rewired our 31K line long codebase to work with this new architecture.

The result? Fearless
installation of packages without panicking about them containing anything evil. All with more than 99% compatibility with all of `luarocks.org`
(yes, we really ran such a test!)

## Looking Onwards

A byproduct of the refactor is that we no longer rely on mlua. This means that we can package Lux more easily for all platforms, and it now allows us to automatically download the appropriate version of the Lux loader for use in Lua REPLs.

In the future, we'd like to pair Lux with native support for
[Luanox](https://beta.luanox.org/), our WIP package hosting for Lua packages.
Luanox is built with maximum security and zero-trust in mind - it's even
resilient against a full leak of our internal databases as we don't store API
keys nor other sensitive data.

We're always committed to ensuring security and usability in Lux. Stay safe and cheers to the next release 🍻
