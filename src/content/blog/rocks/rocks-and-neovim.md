---
title: "Improving Neovim Plugins"
description: "The road to `rocks.nvim 3.0`"
pubDatetime: 2024-12-16
tags:
  - rocks
draft: false
slug: "rocks-and-neovim"
---

## Introduction

Over the past couple of months I've been helping out with an initiative to bring luarocks into the Neovim ecosystem.
If you'd like to read about why, I recommend reading [Marc Jakobi](https://mrcjkb.dev/posts/2023-01-10-luarocks-tag-release.html)'s
post on the matter.

Since that post, we've made [`rocks.nvim`](https://github.com/nvim-neorocks/rocks.nvim), a modern plugin manager that fully
supports versioning, dependencies and build scripts without any user intervention by using a real package manager as its backend.

We're currently on version `2.41.1`, impressive! However, we recently started recognizing some serious shortcomings in Luarocks.
For you, as users, this manifests as general slowness - `:Rocks update` takes a substantial amount, mostly because Luarocks is not
built to run in a concurrent manner.

This, alongside [other issues](https://vhyrro.github.io/posts/rocks-devlog-01/), have led us to develop our own rewrite of Luarocks
in its entirety called [`rocks`](https://github.com/nvim-neorocks/rocks). This also nicely fits our naming - `rocks.nvim` is built
on top of `rocks`, the package manager.

This post serves as an update to show you what level of completion `rocks` is at and how close we are to fully integrating
it into `rocks.nvim` and -- just maybe -- Neovim.

## I am Speed

`rocks` has seen rapid development over the past months. It's now fully capable of concurrent installations and is [several times
faster than luarocks itself](https://vhyrro.github.io/posts/rocks-devlog-03/). So, what's the blocker?

The core of `rocks` is written entirely in Rust, meaning you cannot just plug it into Lua (the language Neovim uses) and be
on your merry way. Integrating `rocks` into the Neovim environment requires a bridge between Rust and Lua.
Thankfully, a tool for this already exists, and is called [`mlua`](https://github.com/mlua-rs/mlua)! The past week
of development time has been spent ~~procrastinating before Christmas~~ developing this Lua bridge. The availability of `rocks` from the Lua
side is a *huge* deal, as it allows us to create an almost drop-in replacement for `luarocks` with proper error handling
and error recovery.

## Omg Neovim hi??

It may be surprising to hear that Neovim has considered a built-in plugin management solution for quite a while now
(think something like `vim-plug` but in core).
It may be even more surprising to hear that integrating `luarocks` has in fact been considered as well, but has been
dismissed mostly because `luarocks` is, as we've discussed in prior blog posts, a big hassle.

If `rocks` were fully interactable from Lua there is always a chance that it could become the defacto backbone for plugin
management inside of Neovim -- how great would that be? One could have access to all of the Lua ecosystem, just a few commands away.

After all of the failures that `luarocks` caused it will definitely take some long discussion to enumerate all of the details
and fixes that `rocks` provides in order to persuade the core devs to give it a shot. We believe it'll be worth it!

## Conclusion

I hope to be done with the Lua bridge by the end of this week. Integrating `rocks` into Neovim should hopefully take little time
after that. Cheers to a better Lua ecosystem! 🪨🪨
