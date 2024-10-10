---
title: "Looking Past Helix's Horizon"
description: "The Ki Editor may have just one-upped the boss."
pubDatetime: 2024-10-10
tags:
  - misc
  - editors
draft: false
slug: "ki-editor"
---

Hi. In case it wasn't obvious from my previous posts, I love wandering into the deep forest that is modern technology.
We take many things in our computers for granted, but only the bravest succeed in actually making real improvements in how we use them.

This blog post discusses Neovim, Helix and Ki's *keybind systems*, to provide a wider perspective.
If you expected a twitter-length post, here's a redirect link to get you right where you want to be: [no problem](https://x.com/).

## Editors Suck

In case it never occurred to you - editors suck. Sorry if this is a revelation,
I may have just inadvertedly sent you down a rabbit hole you had never even
considered. No turning back from the black hole.

What do you do most often in your fancy graphical editor? You flail around, trying to
get your clumsy mouse to highlight the text you're interested in about half the time.
The other half of that time is spent moving your hands from said mouse to your keyboard. In case you did the math, yes,
that's a whopping 0% time actually doing any real typing.

Humans were quick to figure out that we can do better, and - to spare you the boring historical details - we've landed at the current status quo, Neovim.
Its spotlight is undoubtedly its extensibility through the Lua programming language, allowing you to tweak it in any way you see fit. But, just as a car's body
can be impressive, the engine is just as important. And Neovim's engine is so good you can almost feel it through the screen.

At its core, all it does is edit text, and it does so very effectively by employing *modes*. Insert mode behaves like any grand old WYSIWYG editor, it lets
you type things. The magic lies beyond that, in Neovim's normal mode.

Normal mode magically converts your entire keyboard into an array of quick, one-off instructions for the editor to perform. If ya want to **c**hange some text,
you press `c`. If you'd prefer to **d**elete something instead, you press `d`. Upon pressing these keys, Neovim enters an *operator pending mode*, this is the editor
asking the question: what do you want to perform the action *on*?

To drive the point home, here are a few, completely unboring examples of day-to-day Neovim usage:
- `cw` -> change the current word
- `dd` -> delete the current line

There are some exceptions where an operator isn't necessary if the intent is obvious. An example is the `x` key, which removes the current character under
your cursor. It's functionally equivalent to `dl`, for example, but it's there for coziness and convenience.

Coziness and convenience!?? What is this, the '90s? We need that steel, industrial feel. No place for emotions here, we need to do better, harder and stronger.

And thus, say hello to Helix.

## Upgrades People, Upgrades

Neovim will make you feel like you're gliding through the keyboard, as if your thoughts are transferred right to the screen you're gaping at right now.
However, this feeling only truly holds up for simple editing tasks. If you just write notes or edit portions of your sci-fi worldbuilding project nobody will read, you'll
thoroughly enjoy it, I can assure you of that.

We can hit a brick wall very quickly, so allow me to be blunt by giving you a
set of instructions that I'd like you to perform in your Neovim instance right
now: using Neovim keys, refactor all innermost function invocations in a code
file that contain exactly 2 parameters and supply them with an arbitrary third
parameter.

"How is this ever a regular edit a sane human will have to perform?", you may
inquire. This specific example isn't all that important, the point is that we
sometimes need a *particular* level of specificity in our edits, and the
decade-old approach that Neovim takes just doesn't quite cut it. Macros exist,
and an expert Neovim wizard will be able to conjure up an unholy sequence of
keystrokes rather quickly, but trying to invoke these macros is a bit like
trying to drive a sports car across a desert, it's... crunchy.

Let's get to the core of the issue: why is this? What's fundamentally flawed with the tried and tested rut? Surprisingly, it comes down to order.
Neovim first asks the question "what", and then asks the question "where". This is very natural and intuitive, but it's impractical. This model
assumes you always know ahead of time *where* you want to make an edit. And, as you can imagine, trying to convey "all innermost function invocations in a code
file that contain exactly 2 parameters" is not a simple ordeal, bummer.

Helix was supposed to be the answer, and it's quite ingenious - Helix makes you select the text you're interested in *first*, before asking you what you actually
want to do with your pick. This has a profound consequence, it allows you to tweak and adjust your selection before committing to an action. I can initially select
all function invocations, but then I can narrow down my selection until, bit by bit, I make my selection exactly what I want it to be. After that, I can perform the desired
action that I actually wanted to do (in our case, append some text to the selection!).

The best part? I can narrow down this selection using a set of small, simple motions. I don't have to strain my mind at all, in fact the whole process is almost subconscious.
It's a bit serene, too.

Helix has been catching on nicely over the past few months, but I can't help but feel that this model is still awkward. Mind you, it's not as awkward as trying to make a Neovim macro,
but it still feels a bit unintuitive. It feels industrial, in a way. Reduced to its cleanest metals and made to fit the most efficient mold.

It seems I'm not alone. Reading around on Reddit (God save my soul) and HackerNews (God save my soul twice) I've realized that people still aren't quite satisfied with Helix's editing model.
It's like some magic element is missing.

## The Ki Editor (Why do I hear Boss Music?)

When I first read about Ki, I wasn't that impressed, mostly because the documentation site is about as informative as a 40 minute science video. There's lots of talking but little substance, and
you're left wondering whether reading a Vogue magazine was a better use of your time.
I don't doubt that as the project matures, the documentation will improve, but first impressions cannot be changed.

Despite this, I gave it a crack out of sheer boredom, and for the first time in ages, the magic feeling of learning a modal editor was rekindled within me.
In fact, this might just be the endgame of editing for quite some time[^1], seriously!

These guys did the unthinkable, they reduced the editing experience down to its atoms, then proceeded to solve all of quantum mechanics just to make it even cooler.
If you think I'm joking - they managed to implement the selection then action model of Helix *without* majorly changing the vim-like keybinds we're all so used to.

The ki editor adds a third step in the process of text editing. Instead of having an action and a selection, or a selection and an action, you now have the following:
1. A scope
2. A selection
3. An action

When you launch ki, you'll be greeted with an interesting surprise. In both Helix and Neovim, `hjkl` move the cursor around the buffer.
Upon pressing those keys in Ki, you are greeted with silence as uncomfortable as dead air - the editor doesn't even budge. It'll feel like it's pitifully laughing in your mortal face,
a feeling I don't really recommend.

I attempted to flimsily navigate the current buffer by pressing `w` to move to the next word, and then the revelation settled in. Allow me to explain.

In a traditional text editor, navigation keys like arrow keys or `hjkl` move
the cursor to the previous character, the character below, the character above
and the next character. When phrased this way, think about what we're really
doing. We're performing a motion from cursor itself one character in either
direction. This is a good way of thinking of ki's "scope" (what they officially
call selection modes).

When I pressed `w` on my keyboard, I entered what was called the word selection mode, and the current word under my cursor was fully highlighted. Upon pressing `hjkl`, the selection moved *between*
the words in my paragraph. Pressing `d` deleted that very word. Not only that, it automatically highlighted the next whole word, so I can do whatever I want with it! I think I'm on board already.

To highlight whole lines press `e`, and now voila, the whole line is highlighted! You never need to press escape like you do in Neovim, since every keypress will just move you to a different
selection mode. You use escape only is specific circumstances.

### Selection Modes

The power of Ki doesn't end here, however. The specific selections are not just line or word-based, oh no. You can press `s` to highlight the current treesitter node (think current function or class
or definition), you can search through LSP symbols and all of them will be highlighted in one go. You can search using regex, hell, you can even configure your search dynamically using `'`.
When you perform these searches, multiple cursors are implicitly created at every search point - it's like they emerge naturally as a consequence of the editor's design.

Let's say I want to swap two JSON objects around. In traditional, unmodified Neovim, this would involve a nice `vaBVd`, then a `%` to get to the end of the object below, then a `p`, optionally adding/removing a comma
at the end of what you pasted. In Ki, it's the following sequence: `szj`. This highlights the current node, enters "exchange" mode and moves the current object down by one. It even handles commas
for you!

As you can tell, this is a much more semantic way of dealing with your text. Treesitter-based textobjects also exist in Neovim as a plugin, but they do not feel as deliberate as they do here.
Here, they're brilliantly integrated.

Another cool function is the `v` key, which in Neovim enters visual mode; the
same happens here! If I'm already in word selection mode, I can press `v` and
then start selecting multiple words in a paragraph: that's the whole "narrowing
down your selection bit by bit" magic in action here. I really love that all
the visual mode keys work just like they do in Neovim - `o` still moves your
cursor from the start to the end of the selection, it's flat out comfortable.

The best part of all this is that you don't need to change much of your muscle memory. There are some keys that are different (because they *have* to be), but you can still tell that the base
experience is very familiar to Neovim. This is why I'm just so impressed, getting people on board with a completely new technology is always hard, but the Ki developers have managed to stuff
an actual upgrade to something that under normal circumstances would be a measly incremental upgrade.

## Verdict

You thought you knew where this post was going, but I'd like to throw a spanner in the works. I wrote this post because I really, really adore Ki's editing model. However, Ki is more than that,
it's an editor. Here, unfortunately everything breaks down. It's new and, like Helix, it's different. In my opinion, that's a great thing, but being great never directly equals success.
Unfortunately, my take on *editors* as a whole is pretty one-sided: Emacs and Neovim will be the undisputed kings for a long time to come, and I'll dedicate another blog post to that matter.

In an ironic turn of events, I believe that the best place for Ki keybindings... is right in Neovim. Of course, Neovim would never accept them into core, but I really do hope that this post
serves as an inspiration for someone to make a plugin that replaces the Neovim binds with Ki ones - I'd switch to it immediately. A little bit of hydra.nvim, nvim-treesitter-textobjects and LSP
integration and it would be the #1 plugin on my plugin list.

Hope you learnt something.

---

[^1]: Although I encourage others to experiment with new ideas, you never know what you might come up with :)
