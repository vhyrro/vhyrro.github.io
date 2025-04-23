---
title: "Lux Devlog #005"
description: "True Lua projects!"
pubDatetime: 2025-04-23
tags:
  - rocks
  - lux
draft: false
slug: "rocks-devlog-05"
---

Hello, world! This post marks a true moon-landing moment for the Lua ecosystem - Lua projects.

## `lux.toml`

`lux.toml` support has [finally landed](https://github.com/nvim-neorocks/lux/pull/325). This means, at last,
that managing Lua projects is no longer a burden.

Here is an example of a `lux.toml` file:

```toml
package = "my-package"
version = "0.1.0"

[dependencies]
argparse = "0.7"

[build]
type = "builtin"
```

Simple and effective. We made it generally mirror the rockspec format for ease of transition.
TOML files allow us to programmatically edit the project file whenever running commands like the upcoming
`lx add` command.

This change was a very large one and took a lot of work. Excited to see where we can take it from here.

## `lx config`

We've taken the time to implement `lx config`, a way of managing and configuring Lux from a global location.
Run `lx config edit` to edit it using your `$EDITOR`. The configuration file is also written in TOML.

## Bugs say Bye

Since the last post, we squashed several important bugs related to URL parsing and proper detection of the current
platform. These bugs were critical to the functioning of the project, so things should be much more stable now :)

## What's next?

Next, we've got our eyes set on some really important componentry: `lx add` and the `extra.rockspec`.

Not everyone wants to migrate to the TOML system, especially if they have a complicated rockspec. In order to support this
use case, I'm planning on letting projects have an `extra.rockspec` file, which will be merged with the `lux.toml` automatically.

Apart from that, we also want to cram in `lx pack` support - rocks can be packed as binary rocks that can be shipped on a per
operating system basis. If there's something that must be compiled as part of a rock, then binary rocks can be thought of
a precompiled version of that rock.

`lx pack` will be incredibly important for Neorg and `rocks.nvim`, which will both make extensive use of the feature.
Here's to a good Lua package manager!
