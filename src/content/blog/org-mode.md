---
title: "Emacs's Org - The Good, The Bad and The Ugly"
description: "It's the details that count..."
pubDatetime: 2024-03-12
tags:
  - note-taking
  - other-applications
draft: false
---

I just started a blog, and what better way to initiate a new and exciting chapter of my life than start
a flame war on the internet.

In this post I'd like to take a deep dive into the syntax and design of `org-mode`'s well-known format, `org`.

Grab some tea, kick your feet up and come along for the ride.

**Note**: This post will explore all aspects of [`org-mode`](https://orgmode.org)'s file format _specifically_, not
the plugin itself.

## General Introduction

For the uninitiated, `org-mode` is one of the most popular tools available within the Emacs editor.

It allows you to take notes, write journals, craft technical papers, create spreadsheets and much more -- all
in a single file format. This means you only need to learn one file format to gain access to all of the superpowers
`org-mode` has to offer.

Because of this, `org-mode` is easily the most praised organizational tool ever. But how rigorous _is_
the underlying format, really? Is it as great as people make it out to be?

## The Good

I think it's important to begin with the good, and there's a lot of good to talk about. There are plenty of
existing blogs online telling you why to use `org` files, even as substitutes to Markdown!
Just ask any Emacs user what they think of `org` and you'll likely get good responses.

Why are they so positive, however? What makes `org` special? Several things:

1. Org is very intuitive to learn and quickly grasp as a newcomer. Just look at a basic document:

   ```org
   * Welcome to Org

   The following are: *bold*, /italic/, +strikethrough+ and _underlined_

   - This is a list
   - This is another itme
     - And this is a subitem!

   Cooking recipe:

   1. Prepare ingredients.
   2. Mix it all up.
   ```

   You can tell everything that's happening at a glance.

2. Easier to reason about than Markdown - the irony of MD is that despite being advertised as "readable without
   a renderer", Markdown has so many quirky syntax rules that you can never be sure what garble you'll receive
   on the other end when you eventually export your Markdown files to HTML.

   Org (while not perfect) is vastly more robust in its export output, without the whole HTML doing two backflips
   when you misplace an inline image.

3. An extensive set of features - not just extensive, but unobtrusive. You only pay for what you use.
   Not using timestamps? Fine, no problem. But when you _do_ need them, it's handy to have.

4. More elegant - this is completely subjective, but in my time of doing syntax
   design `org` feels like it had looks as a design goal in mind (at least
   compared to Markdown). In my experience of using Emacs and `org-mode` I had
   plenty more fun reading through `org` notes over my Markdown notes. Some
   consider it so clean that projects like
   [orgdown](https://gitlab.com/publicvoit/orgdown) have emerged in attempts to
   make the format usable everywhere.

So, end of story. Org mode has a great file format, and everyone should use it. You can stop reading now.

...

That's not what you're here for! You're here for a flame war! Okay, fine. On the surface, `org` looks like a perfect file format.
But, just like the descrpition of this post says, "it's the details that count".

I truly believe that the file format is like C++ - there's a smaller, more beautiful and more stable language trying to get out. But the harsh
reality is that it's not all sunshine and rainbows.

## The Bad

I earlier said that `org` syntax was crafted with elegance in mind. That's true, however it definitely wasn't designed with practicality in mind.

A lot of features were developed on a per-need basis. There was a use case within `org-mode`, and some syntax was developed to accomodate for it.
This really shows in a variety of places.

### TODO Statuses

A simple example are keywords - TODO statuses are marked as such:

```org
- [X] This is a done task!
- [-] This is a pending task.
- [ ] This is a task I still have to do.
```

However, when you try doing the same thing in a heading, it won't work:

```org
* [X] This is not a done heading
```

Instead, for headings, you use a completely new set of keywords:

```org
* TODO I have to do this
* DONE My heading is done
```

Okay - not the worst in the world. Except it is. These keywords are _configurable_ - this is a common trend you'll find throughout the format and it's painful to see.
TODO keywords are configurable both in the file itself as well as within Emacs itself. This means that a parser can't just look for a predetermined set of keywords,
it has to be prepared for theoretically _any_ text to appear in place of the `TODO`/`DONE` keywords.

Not to mention, these TODO keywords are plenty and are more expressive than regular TODO statuses.
This means that you can't represent every state that you'd find in a heading in a list.

### Usablity Outside Emacs

I alluded to this in the previous section, and it's a very real problem - lots of `org`'s features
are gated or configurable from within Emacs itself. This means that writing a cross-platform parser
that fully supports `org` is physically impossible. You can always cut corners and make compromises,
but it'll never be the Emacs experience™.

Even if the user configured their format in a self-contained way (by defining all of their configuration
within the file itself) a parser would have to dynamically read data from the file and alter its behaviour
based on that. This is something that, in common parser generators like [tree-sitter](https://github.com/tree-sitter/tree-sitter),
is very difficult to do.

This is why you most often hear praise of `org` from Emacs users themselves and
not others - supporting `org` _properly_ outside of `org-mode` is a monumental
undertaking which requires you to either make assumptions about the users'
documents or expose counterparts to Emacs's configuration options within your
own application. The format does not scale well anywhere else, and Markdown
continues to reign supreme.

### Multi-Language Support

Emacs has trouble with properly enforcing its markup rules in languages other than English.
When I say markup rules, I'm specifically talking about inline markup: `*bold*`, `/italic/`, etc.

According to the official specification (which generally follows the behaviour of the original `org`
parser), for an opening character like `*` to be parsed it must be preceded by a specific set of characters,
all of which are ASCII. For a closing character (the second `*` in `*bold*`) to be parsed it must be succeeded
by a **different** set of characters, all of which are also ASCII.

Not only are the opening and closing character sets different, they also don't account for much of the natural language
spectrum. A better approach would be to generalize the conditions to a spectrum of Unicode categories that
could be hand picked by the developer team -- it would definitely provide more possibilities for non English
writers.

### Zero-Column Headers

This is a fairly minor nitpick, which is why it is still under the "The Bad"
section. Headings can only be defined at the very beginning of a line. This
means headings cannot be indented whatsoever, which may come as a bummer to
some, since `org` leans in on the idea of a "tree-like" data
structure for notes. This is unlike Markdown where headings are simply delimiters for
text.

Examples:

- ```org
  * This is fine
  ** And so is this
     Hello world!
  ```
- ```org
  * This is fine
    ** But this is not
       Bye world :(
  ```

I think the most mildly annoying part about this is that there is no real
reason to enforce this from what I know (couldn't find anything about it
online).

From a syntactical standpoint, there is no ambiguity when the user
adds some spaces in front of their headings, unless `org` automatically assumes
that after some whitespace a paragraph will follow, therefore treating the
whitespace before a paragraph as the content of the paragraph itself - in which
case I have some terrible news for the syntax designers -- they didn't do a
good job :P

## The Ugly

This is the section where all pandemonium breaks loose. Now, instead of discussing `org` as a whole,
let's look into some of its less known syntax. You might just end up laughing at some of these.

### Angled Links/Regular Links

Within `org` there are three ways to define a link:

- `https://my.link`
- `<https://my.link>`
- `[[https://my.link]]`

Yes, they all do the same thing. No, nobody will explain to you why there are three ways of defining
a link.

### Zeroth Section

Some syntax is disallowed in the file format if it belongs in the _zeroth section_. This section
includes all of the lines of your document before the first heading.

Everyone knows that the best way to design a system is to implement odd and unpredictable exceptions
to the rules you make... at least that's what Richard Stallman told me.

### Embedded Latex Environments

As a concept, these sound great. They allow you to create math environments directly within
your document:

```org
* Latex Showcase
\[
Hello, \LaTeX!
\]
```

The reality is, this syntax is complicated and generally quite useless.

There is an inline syntax, `$$Hello, \LaTeX!$$`, as well as the syntax required
to implement a block-level math mode:

```org
#+BEGIN_MATH
Hello, \LaTeX!
#+END_MATH
```

Moreover, the `\[\]` and `\(\)` syntaxes are fairly fragile if used in a wrong place.

I am aware that the `$ $` inline math syntax is generally hated amongst the `org` community.
This is because the syntax rules for inline markup are too lenient to permit proper LaTeX inside.

In a perfect world, this would be fixed by making the inline markup rules more rigorous, instead
of inventing syntax around the problem - given that `org` is over _20 years old_ now, it will probably remain like this.
That's just the way of software development.

### Zero-Width Space as Escape Char

This... this keeps me up at night.

In Markdown and everywhere else, when you don't want a character to be interpreted as special
you escape it with an escape character (usually backslash: `\`).

`org` decided to be special, as `\` is already reserved for [embedded latex environments](#embedded-latex-environments).

To escape a character, _you prefix it with a zero-width space_.
Zero width spaces are rendered by almost all editors as if there was nothing there.
Someone will open your `org` document, see that some syntax bits are not working without any explanation,
and will assume your document is broken.

If anyone opens up your file outside of Emacs, they'll also be in for a massive surprise.

Then there's the question of even _typing_ a zero-width space in the first place. Not every editor
is called Neovim or Emacs, typing out a quick control sequence to enter an esoteric character is
not something readily available to everyone.

In my honest opinion, this is pure madness.

### Radio Links

If you ever feel like solving an O(n<sup>1000</sup>) problem this one's for you!

Radio links allow you to do links, but without the links. Here's an example:

```org
This is some <<<*important* information>>> which we refer to lots.
Make sure you remember the *important* information.
```

Because we marked the `*important* information` in three (!) whole angled brackets any occurence
of that text will now auto-create a link to the source.

I mean, I can see _why_ this was implemented. But perhaps we should have stopped to think if we even _should_.
Computationally this sounds like a doozy.

### Affiliated Keywords/Metadata

The `#+KEY: VALUE` syntax is a great idea that generalizes the way we attach metadata to our notes if not
for the fact that this syntax makes very little sense.

When used standalone, it defines metadata for the current document:

```org
#+TITLE: My Cool Document
```

When put right above an object, it attaches itself to the object:

```org
#+name: Custom name
[[file:something.txt]]
```

So far so good. But these syntax elements can also reference items before themselves, take for instance spreadsheets:

```org
|---+---------+--------+--------+--------+-------+------|
|   | Student | Prob 1 | Prob 2 | Prob 3 | Total | Note |
|---+---------+--------+--------+--------+-------+------|
| ! |         |     P1 |     P2 |     P3 |   Tot |      |
| # | Maximum |     10 |     15 |     25 |    50 | 10.0 |
| ^ |         |     m1 |     m2 |     m3 |    mt |      |
|---+---------+--------+--------+--------+-------+------|
| # | Peter   |     10 |      8 |     23 |    41 |  8.2 |
| # | Sam     |      2 |      4 |      3 |     9 |  1.8 |
|---+---------+--------+--------+--------+-------+------|
|   | Average |        |        |        |  25.0 |      |
| ^ |         |        |        |        |    at |      |
| $ | max=50  |        |        |        |       |      |
|---+---------+--------+--------+--------+-------+------|
#+TBLFM: $6=vsum($P1..$P3)::$7=10*$Tot/$max;%.1f::$at=vmean(@-II..@-I);%.1f
```

The table references data that is defined _after_ the table itself in the `TBLFM`, thus, the `TBLFM`
also affects the table before it.

I guess nobody could make up their mind whether this syntax should go standalone, before or after, so
everyone unanimously said "yes" to everything.

### And More...

I'm not just saying that to sound negative. There are more intricacies that
generally make you go "why?", but are too technical or nuanced to get into in a
single blog post. I may make some follow up blogs describing those in the
future.

## Conclusions

I don't want to leave this post on a negative note. I did not restrain myself from roasting the format near
the end there, but I don't want the takeaway to be that `org` is a _bad_ format per se. Rather, I believe that
criticism is equally important to praise, and I wanted to show both sides of the coin today.

In the end, a tool is a tool, so we should use it where applicable.

By the way, I have even harsher thoughts about Markdown, which I will create a post for soon-ish.
Nobody is safe around here 😂

Happy note taking! Watch out for those zero-width spaces while you're at it.
