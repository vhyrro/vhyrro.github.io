---
title: "Neorg 9.0.0"
description: "Calendars, Keybinds & More!"
pubDatetime: 2024-07-15
tags:
  - neorg
  - breaking-changes
draft: false
slug: "neorg-9-0-0"
---

Neorg `9.0.0` is here and it's one exciting release! The calendar has been stabilized and is now loaded by default in Neorg. The keybind system has
been rewritten from the ground up to be entirely inline with the "Neovim" approach.

Since this is a new major release, that means there were several breaking changes, let's go over them one by one.

## Luarocks Refactors

Since `8.0.0` was released, `folke` has implemented luarocks support directly within `lazy.nvim`. This means that you no longer need any of the previous build steps required
to make Neorg function! Post-`9.0.0`, your configuration can become as simple as:

```lua
{
    "nvim-neorg/neorg",
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = true,
}
```

Isn't that just great! There is still one requirement of course -- `luarocks` must be installed
and present on your system. We recommend just installing using your system's package manager.
You can get a list of commands for various operating systems on the [kickstart page](https://github.com/nvim-neorg/neorg/wiki/Kickstart#prerequisites).

## Hello, New Keybinds!

The keybind system has been massively overhauled as part of the `9.0.0` release and is easily the star
of the show here. The keys you use are still the same, but the underlying system is now designed to be
unobtrusive and simple, just like the Neovim overlords intended.

First and foremost, Neorg will fully respect the keys you've set in your config. If there's
a conflict with your configuration, Neorg won't forcefully override your keybind. You can see
which keys cause conflicts in the healthcheck: `:checkhealth neorg`!

Moreover, the `:Neorg keybind` command has been removed in favour of migrating all our mappings to
use `<Plug>(neorg.keybind-name)` instead. This makes the project more accessible to vimscript users but, more importantly,
allows us to do something we couldn't do without `<Plug>`: *automatic remap detection*.

[This page](https://github.com/nvim-neorg/neorg/wiki/Default-Keybinds) gives you a list of all keys that Neorg binds by default. Clicking on each dropdown
will show you what `<Plug>` mapping that key binds to.
Want to remap any of those keys? Go for it:

```lua
vim.keymap.set("n", "my-key", "<Plug>(neorg.dirman.new-note)")
```

When Neorg starts up, it'll recognize that you've bound your own key and will not create any of its own. Compared to the old approach, which
required a complex DSL and special keybind callback, this is endlessly more ergonomic. See the [keybinds wiki](https://github.com/nvim-neorg/neorg/wiki/User-Keybinds) if you'd like
to read more.

## Farewell, `core.mode`

Active users of the various Neorg modes (like `traverse-heading` or `traverse-link`) will be disappointed to hear that the `core.mode` module has been removed entirely
from the codebase. While the idea was great for its time, this module has proven to greatly complicate almost all aspects of Neorg, especially the keybind system.

In the future, we plan on substituting the old features of `core.mode` with a more modern approach. We're currently thinking of making `hydra.nvim` an optional dependency
and reimplementing the things that made Neorg modes so great in a better and more polished package!

## Neovim `0.10` my Beloved

Neorg has bumped the minimum required stable Neovim version for this release to `0.10`. This allows some new modules to be loaded by default, most notably the calendar:

![calendar view](@assets/images/neorg-calendar.png)

Gorgeous. **Important note: nightly builds of Neovim are not officially supported by Neorg. If it works, great! If not, we highly recommend moving back to a stable release.**

## ~~Connect~~ Repeat the Dots

Dot repeat (`.`) has been expanded in this release. You can now dot repeat any action that modifies the buffer, including setting TODO states on an object.

## Tangling

`core.tangle` has been given a new option: `tangle_on_write`. When enabled, the current file will be tangled every time you save the file.

Furthermore, tangled files are now relative to the host file instead of Neovim's current working directory. Much more predictable!

## Conclusion

So, what's next? We know that GTD is constantly on everyone's radar, to the point where "Neorg GTD" is the second most searched google result related to Neorg.

It's very likely that Neorg `10.0.0` will be the first release to showcase a client integration with norgopolis and all the other backend systems that will power GTD one day.
We're not trying to rush anything here, we do not want to break people's notes in places where we shouldn't. You can bet you'll hear from us on the day that the most powerful
Neorg workflow is finalized, though!
