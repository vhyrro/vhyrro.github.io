---
title: "Neorg 8.0.0"
description: "'Why is my Neorg installation broken?'"
pubDatetime: 2024-03-18
tags:
  - neorg
  - breaking-changes
draft: false
slug: "neorg-and-luarocks"
---

## Neorg Breakages

If you're reading this, it's likely because you saw the breaking change popup
within your editor, have seen the new Neorg README, and have been directed to this page.

Neorg's latest release, `8.0.0`, has been quite a milestone but also a large breakage
for existing users.

If you want a fix, and don't care about reading _why_ we made the changes, jump
straight to [the fix here](#the-fix).

## What's Luarocks?

[Luarocks](https://luarocks.org) is the official Lua package manager. It handles projects,
dependencies, build scripts and more for any program made in Lua.

The easiest way to think of it is as a `cargo`/`crates.io` for Lua projects (and by extension Neovim plugins).

For more information on why Neovim + Lua is a fantastic combo, look no further than [Marc's blog
post](https://mrcjkb.dev/posts/2023-01-10-luarocks-tag-release.html) as well as [the rocks.nvim README (why rocks.nvim?)](https://github.com/nvim-neorocks/rocks.nvim?tab=readme-ov-file#why-rocksnvim).

## Where does Neorg fit in?

While there have been dozens of plugins which have uploaded their plugins to luarocks already (`telescope`,
`luasnip`, `nvim-treesitter`, `rest.nvim` and more), Neorg is the first to make the leap towards treating luarocks
as a first-class citizen.

We did not do this without reason, of course. Sure, luarocks creates a slight
inconvenience to you _now_, but has massive positive consequences later
down the line:

- Dependencies are handled by us, not you (you'll never have to update your
  dependencies again!)
- Versioning of all internal parts of Neorg are handled automatically (breaking
  changes are much less impactful this way)
- Build scripts (including the automatic setup and installation of `tree-sitter` parsers)
  are managed by us - this ensures a more stable first-time installation experience
- We gain access to the entire `luarocks` repositories and all of the code available there - this
  maximizes code reuse and makes implementing otherwise complex features a breeze.

  An example is fuzzy finding - implementing a fuzzy finding algorithm from scratch is tedious,
  installing the `fzy` luarock gives us a fully-featured and well-tested repository right at our
  fingertips. Less bugs, less work.

- _Luarocks is critical for the upcoming GTD implementation to function_. This part will be discussed
  in further detail in another blog post :p

## Backwards Compatibility?

Since we've made the switch to `luarocks`, what does this mean for `lazy.nvim` users?
Are `luarocks` and `lazy` mutually exclusive? Not at all, both can be used in unison.

Packer used to support `luarocks` out of the box back in its hayday. Unfortunately, `lazy.nvim`
does not support `luarocks` in any capacity, [and likely never will](https://github.com/folke/lazy.nvim/issues/37).

That's fine though, because we can continue to retain backwards compatibility ourselves with [luarocks.nvim](https://github.com/vhyrro/luarocks.nvim)!

The `luarocks.nvim` plugin compiles a local version of `luarocks` that can be accessed directly within Neovim, no setup required.
It does this by exploiting lazy's `build.lua` file to automatically run the respective build code.

Then, other plugins that rely on `luarocks` can require this plugin as a dependency and everything will just work™.

## Things May Break!

This is a first-generation plugin of its kind (which doesn't rely on `hererocks` as its backend for compilation),
thus on esoteric architectures or system configs things might break!

I encourage you to approach the issue with some patience, and please do report all bugs on the [issue tracker](https://github.com/vhyrro/luarocks.nvim/issues)
so that I can fix them ASAP!

Once we get past the initial wave of errors, the future is looking really bright for the functionality Neorg will be able to provide.

## The Fix

Below we list three different ways of coping with the new changes.

### Adapting Your Config

If you're on `lazy.nvim`, the fix is contained within the next two headings below.

#### Prerequisites

First, ensure that you have either `luajit` *or* Lua 5.1 installed on your system.
This is the version of Lua that Neovim uses, but for some reason isn't vendored
on a large chunk of people's machines.

Here's the list of commands for all major OSes:
- MacOS (brew): `brew install luajit`
- Windows: [use the lua for windows installer](https://github.com/rjpcomputing/luaforwindows)
- Apt: `sudo apt install liblua5.1-0-dev`
- Dnf: `sudo dnf install compat-lua-devel-5.1.5`
- Pacman: `sudo pacman -Syu lua51` or `sudo pacman -Syu luajit` (choose which you prefer)

#### Changing the Configuration

Once you have the prerequisites, simply change your configuration to the following:

```lua
    {
        "vhyrro/luarocks.nvim",
        priority = 1000, -- We'd like this plugin to load first out of the rest
        config = true, -- This automatically runs `require("luarocks-nvim").setup()`
    },
    {
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        -- put any other flags you wanted to pass to lazy here!
        config = function()
            require("neorg").setup({
                ... -- put any of your previous config here
            })
        end,
    }
```

This snippet assumes you're on a custom-built, personal configuration. If you're using a distribution
like AstroNvim, LazyVim or others be sure to refer to the respective documentation and manuals for how
to manage and add plugins.

As long as you are installing `luarocks.nvim` and make it a _dependency_ of `neorg` then
the entire build process should succeed!

If you have any odd errors during the installation process, feel free to check out the [dedicated thread on Github](https://github.com/nvim-neorg/neorg/issues/1342).
The most common fix is to manually run `:Lazy build luarocks.nvim` and then `:Lazy build neorg`!

### Pinning to `7.0.0`

If Neorg's functionality is critical to whatever you're working on, feel free to pin Neorg to the older `7.0.0` release instead:

```lua
    {
        "nvim-neorg/neorg",
        version = "v7.0.0", -- This is the important part!
        config = ...,
    }
```

I encourage you to at least try the new release and -- if you have any errors -- report them to me either through the bug tracker or Discord!
After that you're free to rollback to the `7.0.0` release as a fallback and continue taking notes as if nothing ever happened.

### Migrating to Rocks.nvim (optional)

In case you're looking for something new/fancy, [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim) is a new Neovim
plugin manager that uses `luarocks` under the hood for all of its operations (unlike `lazy` or `packer`/`pckr` which all use `git`
as the underlying engine).

With it, installing Neorg involves running: `:Rocks install neorg`, with everything else being fully automatic.

I'll always make sure to maintain full compatibility with `lazy.nvim`, so don't let FOMO get the better of you!

Thanks for reading! Happy note-taking.
