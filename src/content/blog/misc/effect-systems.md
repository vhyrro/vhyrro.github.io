---
title: "Moving Beyond Type Systems"
description: "Is another programming revolution possible?"
pubDatetime: 2024-05-31
tags:
  - misc
  - programming
  - type-theory
draft: false
slug: "effect-systems"
---

## Introduction

This post is the first of a series called "pondering about what we could do better in the programming world because I have time to waste".
In this post I would like to introduce the idea of a static effect system and how it could be beneficial to
programming languages moving forward.

> Math has a tendency to reward you when you respect its symmetries.
> - Grant Sanderson (3blue1brown)

I'd like to start off with this quote because it very nicely scales to other fundamental domains. Language design is one of these.
When we recognize the fundamental components of what make a system tick, we can complement those behaviours to create something beautiful, or at the very
least extensible and functional.

With this quote in the back of our minds, let's address an issue present in the programming space currently: effects.

## Effects In Present Day

Ever since the dawn of programming languages effects have been quite the hot topic, but only recently has the idea boomed into the mainstream of programming.

**An effect is a consequence of something happening in our program**. This could be modification of data outside of the current function, or printing something to
the console (accessing I/O), or fetching something from the internet. Some effects are predictable as they're consciously implemented by the developer of the program.
Other effects, like changing control flow because of an exception, are out of reach and not controllable by the developer as they depend on outside factors.

We've since had two sides in the programming space: *imperative languages* - which operate on a step-by-step basis, and *functional* languages - which operate on a higher-level, more declarative basis.
Imperative languages permit all sorts of side effects, since state throughout the program is managed entirely by the developer of the application, whereas functional
languages eliminate the concept of side effects (and permit them only in "controlled" environments, e.g. through monads) in an attempt to reduce bugs in code.

To this day we're pretty used to either having *all* side effects under our control or having *no* side effects. What if we could strike a balance?

You may try to look far and wide to find such a language that uses such a concept right now, but it's been here for a while - Rust. Rust tries to limit the side effects of a program by enforcing
certain rules which are governed by the borrow checker. You can't use an owned variable twice, you can't mutate a value unless explicitly annotated, you can't move a value outside of its own lifetime.

People don't usually think about it in this fashion, but Rust attempts to constrain the possible effects that a program can have in its own, limited way. It does so by statically evaluating
a program's control flow and reporting anything it doesn't like.

## Effects in Present Research

As you may imagine, being able to **tame** effects (instead of flat out removing them and then "readding" them like functional languages) is a pretty lucrative idea, and could be the next big thing since
the borrow checker in programming languages.

To nobody's surprise, there are already several papers and research going on about "effect systems", to the point where [they have a wikipedia entry](https://en.wikipedia.org/wiki/Effect_system).
There are already languages that tame effects and allow you to reason about them as types. [Koka](https://koka-lang.github.io/koka/doc/index.html) is my personal favourite!

These programming languages allow a developer to define and handle various effects that may occur throughout your application. Upon encountering an effect you can run some special handler code
that will ensure that nothing unintended is happening in your program.

Nice! So, we already have research going on in this area, cool... except...?

## Something's Fishy

Effects are represented as algebraic data types in type theory. If you'd like to understand them in layman's terms, I highly recommend [this blog post by Dan Abramov](https://overreacted.io/algebraic-effects-for-the-rest-of-us/).

There's something that struck me as... wrong, when reading through all the research papers and all of the programming language specifications. Recall the quote from
the beginning of this post, does this concept really respect the symmetries of the system? Let's inspect how a type system works.

A type in a type system generally remains the same size and/or shrinks. Don't believe me? Take the following snippet:
```rust
let x: string = "hello world";

x = 32;

print(x);
```

If we assume that the above language is a strongly and statically-typed language, then you would expect the code to error out. What fool tries to change the type from a `string`
to an `int`?

This is what I mean by remain the same or shrink -- the type doesn't become `int or string` - in the best case the type can only become *more* constrained (e.g. a `Vec<T>` being constrained into
a `Vec<String>`)[^1].

This is fine and dandy, but we now want to embed effects in a type system. How do effects behave? Let's assume we have a snippet like this, in which two statements fire their own, respective
effects:
```rust
{
    print("Hello"); // this fires an effect named "console"
    x = "other string"; // this fires an effect named "mut"
}
```
In the above code, we have two side effects in our program. One of those is accessing I/O and the other is mutating a variable. Now, if I asked you: "what are the effects of this program?"
you'd likely respond with `console and mut`... wait. That goes against the general behaviours of a programming language's type system! Effects naturally *grow* throughout the duration of the program, not shrink.

If we want to truly respect the symmetries of the system, we need to rethink the situation from the ground up. Trying to forcefully mold effects into types might not be the best idea after all.

## There are Two ~~Type~~ Effect Systems

What I was quick to realize is that there are two distinct ways of implementing an effect system -- static and dynamic. What present day research is trying to figure out are *dynamic* effects.
You create callbacks that handle different state changes in the program accordingly (see that blog post linked earlier if you're not familiar).

A *static* effect system would be something akin to Rust's borrow checker but for effects -- instead of being able to interact and handle effects through functions,
the programming language instead has an effect checker that statically analyzes the program and makes sure that everything holds.
This would mean making sure that all effects are annotated properly and that no side effects occur where they shouldn't.

Contrary to the dynamic approach, in a static system you have to *prove* to the effect checker that your code doesn't do anything funky. If you can't prove that some function
doesn't have a side effect, that's an error. Drawing parallels to the borrow checker once more: if you can't prove that a variable will be used only once in a closure, the borrow checker
will complain.

The rest of this post will now focus on implementing a static effect system and how it might be beneficial to future programming languages.

## There are Two Type Systems

> But wait, surely effects can still be represented as types? How else would you quantify and classify them?
> - You (probably)

If that's what you asked, you're entirely correct. An effect system is still its own form of type system. What I would like to show in this blog is that it might makes sense to have
*two* type systems running simultaneously - the regular type system that we're all used to and the effect system.

"Insanity," you may think? There are several upsides to this; for one, both systems can run entirely in parallel over the codebase (I'll showcase how this is possible later), speeding up compilation times.
Second, it allows the effect system to operate in its "natural environment", i.e. an environment where types *grow*, not shrink. As it turns out, data types are completely unrelated to effects, even though
both can be represented via a type system.

## The Theory

This one's important, you don't want to miss this :)

Let's start off from ground zero by implementing a programming language from scratch. I'll be using almost arbitrary syntax in this blog, syntax is merely a vessel for the ideas backing
the language. Before we start cooking up anything concrete, we must establish our ground rules.

### Effects

What **is** an effect, anyway? In this hypothetical language (which I'll call `effecta` because it sounds cool), an effect should be *any* change to *any* state.
This sounds generic, but a generic foundation allows us to apply a question to everything we do to make sure it respects the symmetries of our system.
Our question in this case will be: "is this thing an effect?", and the answer will be "it is an effect if and only if it is a change to some state".

With that in mind, let's start enumerating a bunch of different constructs we find in programming languages to check if they qualify as an effect in our language.

1. The first and simplest example would be the mutation of a variable. Mutating a variable is the purest form of mutating some sort of state (our variable in this case).
   What about creating a variable? Well, creating a variable is creating new state, but it's not *changing* the state, therefore creating a variable is not an effect, but changing it is.

2. Next up, loops and conditional operators (`if`, `while`, `for`): on their own, these constructs do not change any sort of state[^2], but their bodies might change state.
   Thus, loops and conditional operators are effectful if and only if their bodies are effectful.

3. Functions: they follow a similar pattern to loops and conditional operators, they're effectful only if their body is effectful.

4. External resources (files, I/O): this would be a very difficult topic if not for our simple question. Only *writing* to a file or outputting to an I/O stream is considered
   an effect, as only the process of writing mutates external state. Reading data creates new state, but does not modify it, therefore reading data of various sorts is not an effect.
   Because of this, printing is effectful, but reading from stdin is not.

5. A variable going out of scope: this is also an effect! Creating state is not an effect, but destroying state should absolutely be recorded by the effect system.

In addition to the above, an effect has two properties: the subject and its lifetime. The subject is what was affected by the effect, whereas the lifetime is the range of the effect.
For instance, if an effect occurs within a function, then the lifetime of the effect is equal to the lifetime of the function body. If an effect happens to a specific variable, the subject
becomes that variable and the lifetime of the effect is equal to the lifetime of the variable.

Lifetimes allow us to reason about the importance of an effect and also allow us to emulate a basic borrow checker using simple rules!

Not sure if you also came to this conclusion, but Rust's concept of lifetimes fits *more nicely* in an effect system than a type system, isn't that interesting!

### Explicit Effects

Our language should require *all* effects to be explicitly annotated (this ensures that the developer is aware that such effects take place).

## The Basic Syntax

For our `effecta` language I will generally follow Rust's syntax - not because it's particularly great, but because it's familiar to most people and gets the job done.

### Hello, World!

Let's consider a simple hello world program:

```rust
pub fn main() -> () {
    println("Hello World!");
}
```

What you'll immediately be hit by is an error from `effecta`. Your program has a side effect and you didn't acknowledge it! The standard library calls this the `io` effect,
so let's tell the effect checker "yes, I want my program to have this side effect":

```rust
pub fn main() -> [io] () { // ...
```

Here we say that `main` has a side effect of accessing `io`, and the effect checker agrees and lets the code compile. For brevity, when specifying a single effect, we can drop the
square brackets to instead get:
```rust
pub fn main() -> io () { // ...
```

You may have several questions right now, including the developer experience of such design - all will be explained later.

### Hello, Variables!

We define a variable using the following syntax:
```rust
let message = "Hello World!";
println(message);
```

Let's try to modify that variable before we send it into the print function:
```rust
let message = "Hello World!";
message = "Hello Mars!";
println(message);
```

**Oops**, error! Remember what we said earlier? Mutation is an effect, and all effects must be annotated. Effecta calls this the `mut` effect, and so we must annotate our
variable:
```rust
let [mut] message = "Hello World!";
// ...
```

But hold on, we can drop the brackets, since there's just one effect:
```rust
let mut message = "Hello World!";
// ...
```

We just recreated the actual Rust syntax using a pure effect system, mind blown :0

## Guessing Game

As an exercise, let's make a slightly overcomplicated guessing game to internalize everything you know so far:
```rust
use io; // Allows access to input/output streams
use random; // Allows generating random numbers

/// Read the next guess and store it in `output`
pub fn read_guess(mut output: int) -> () {
    output = io.read_int("Take a guess (0-100): ");
}

pub fn main() -> [io random] () {
    let mut guess = 0; // Initialize the user's guess
    let random = random.between(0, 100); // Pick a random number between 0 and 100

    loop {
        read_guess(guess);

        if guess < random {
            println("Aim higher!");
        } else if guess > random {
            println("Aim lower!");
        } else {
            println("You got it!");
            break;
        };
    };

    println("Thanks for playing!");
}
```

Easy enough! One detail: generating a random number also issues an effect called `random`, as we need to mutate the internal state of the RNG engine to prepare the next number.

`read_guess` has no side effects, and so nothing is annotated. However, it *does* actually have a side effect, it's just that we wrote it using shorthand notation.
We already marked the `output` parameter as `mut` in our function definition, the effect system has expanded it nicely for us:
```rust
pub fn read_guess(output: int) -> [mut: output] () { // ...
```

It was able to do this for a simple reason: because we annotated the `output` variable as `mut`, that means we *must* perform some sort of mutation in the body of the `read_guess` function.
Otherwise we wouldn't have marked the variable as `mut` in our parameter list. This is different from the notion regular programming languages have: once something is marked "mutable",
it's mutable forever. This isn't the case in an effect system: you mark something as `mut` to specify "I will mutate the variable in *this* scope", and this property must hold as the effect
system inspects the call stack.

While our `read_guess` function issues effects on other variables, it itself does not trigger any side effects. Such a function can be considered pure.

Wait... what? Pure? If you know anything about functional programming, this is **not** a pure function. It's mutating a value!
... but must it? When an effect acts on a variable, the effect is *controlled* (the effect has a single destination). Think of this logically - if we remove
all parameters of our function then all the effects will disappear, right? The `read_guess` function can therefore be rewritten as follows:
```rust
pub fn read_guess() -> int {
    return io.read_int("Take a guess (0-100): ");
}
```

If we exclude the I/O interactions, this is what functional programmers would consider "pure", but isn't this functionally equivalent to the above example? In the end, it
achieves exactly the same result, and doesn't mutate any other external state. In fact, both functions produce the exact same outputs, just in a different way.
Therefore, using the effect system, we can *prove* that certain functions can be rewritten into a "pure" format, even if it doesn't seem so on the surface[^3]!

## Creating Effects

These magical effects you see called `io` and `random` aren't actually arbitrary. Effects are always based on a set of other, simpler effects.

The simplest effect type is the unit effect, which others can be based on. In the case of I/O, the `io` effect is simply an alias for `mut: std::io::OutputHandle` deep within the standard library
of `effecta`.
This is because, to print something to the standard output, you need to mutate the output handle to write text to it. All the code does is alias that operation
into a simpler to write `io` effect that we can then specify in our code.

In the case of the `random` effect it could be a collection of many different effects that the state engine needed to issue in order to function. I say could because the standard
library doesn't exist yet, we're making a hypothetical implementation here :)

## Local Effects / Effect Pruning

As mentioned earlier, effects have a subject and a lifetime. What's the lifetime used for, anyway? It's used to rule out local effects - effects that happen, but are unimportant
in the context of the program they're running in.

Imagine a program like this:
```rust
pub fn return_5() -> int {
    let mut a = 3;
    a += 2;
    return a;
}

pub fn main() -> io () {
    println("The function returned:", return_5()); // Prints "The function returned: 5"
}
```

A question to you: should the `return_5()` function have a `mut` effect? After all, it mutated a variable, that surely means that the function itself should also have a `mut` effect!
You could say that this is not the case because the subject of `mut` is the variable `a`, not the body of `return_5()` - and you'd be right! But, in the guessing game example,
the mutations to the `output` parameter still caused the effect `mut: output` to be propagated to the outer function.

In this case, the effect will *not* be propagated thanks to the concept of local effects. Let's consider the lifetime of `a` for a moment (which we will call using the notation `'a`) - it gets created
inside of the `return_5()` function, gets mutated, then gets moved out of the function through `return` -- it only exists for a moment, then disappears.

The rule is as follows: an effect will not be propagated if its lifetime is smaller or equal to the lifetime of the target.

To test your intuition: let's say we create a global variable (*gasp*) and try to mutate it from our `return_5()` function:
```rust
let mut a = 3; // This is a global variable that lives for the duration of the program.

pub fn return_5() -> int {
    a += 2;
    return a;
}

pub fn main() -> io () {
    println("The function returned:", return_5());
}
```

Does the `mut` effect have to be annotated? Of course it does! The lifetime of `a` is larger than the lifetime of the function body, therefore you must add
a `[mut: a]` annotation to `return_5()`.

If all of this is the case, why do functions like `println()` have effects? This is because variables like the `OutputHandle` live longer than the `println()` function itself (there's usually one output
handle for the entire duration of the program), therefore the mutation of such a variable is propagated and also must be handled by us in our `main` function.

It's a simple rule, but quite a powerful tool for removing unnecessary noise as we write our program.

### Total Functions

Given this knowledge, we can now classify "total" functions. These are functions that have no effects whatsoever - no effects on parameters, nor containing external effects.

Our initial `return_5()` example was an example of a total function. It received $x$ amount of inputs (in this case 0 since there were zero parameters) and returned
the exact same output given the same inputs **every. time.** Even though it would mutate some data internally, it would end up producing the same output in the end, no matter what.
Another example of a total function would be:
```rust
pub fn add_5(x: int) -> int {
    return x + 5;
}
```

If you pass in `5`, you'll always get an output of `10`. Using the effect system we can guarantee that this is the case without relying on functional programming languages!

## Developer Experience

We're now approaching the end of the blog, so I'd like to address some practical concerns, most notably developer experience (DX).
All effects of a program must be annotated at every step of the way... isn't this incredibly cumbersome?

The answer is: it absolutely is, but there are some magic parts I haven't talked about yet.

### Prototypes

When you declare a function with the `fn` keyword you must annotate all effects. When you're quickly writing programs or whipping up temporary fixes you don't want
the effect system getting in your way. For this reason, it's possible to instead create a function using the `proto` keyword:
```rust
proto my_function() -> () {}
```

When a function is marked as a prototype, the effects of the function are *inferred*. That's right, effect inference!

The great thing about this is that it doesn't *disable* effects entirely. If you do something very wrong (like trying to mutate a non-`mut` variable), you'll still
absolutely be shouted at by the effect system. It just allows you to not have to worry about the effects that are happening in that function.

Changing the `proto` keyword to `fn` will then force you to start annotating effects again - you'll want to do this before shipping a release build of your project
to ensure that the program is doing exactly what you expect.

### `--prototype`

When debugging, it should be possible to invoke the `effecta` compiler with a `--prototype` flag which will treat *all* functions in your code as `proto`s.
This is another debugging aid which allows you to iterate on code faster at the expense of verifying the integrity of your program at all times.

It's quite amazing how much tooling can be built around an effect system like this. Such a system also solves one of Rust's issues, which is the
inability to disable the borrow checker without disabling all safety features through `unsafe`.

## Relation to Types

Throughout this post I haven't mentioned traditional types a single time. This was to prove a point - effects have *nothing* to do with regular old types!
Despite being representable in a type *system*, they don't have much resemblance to types as we know them. An effect always happens on a *variable* or on a *function* with a given lifetime,
but we never care about what type that variable or function is.

Because of this, both the type system and the effect system could run entirely in parallel during compilation, each analyzing the program according to its own rules!

## Conclusion

This post was a collection of thoughts I had about an effect system and how it could be greatly beneficial to post-modern programming languages.
Just imagine how intricate optimization algorithms could get with knowledge of effects like this! However, this post is not complete.
The system still needs to be tried in the real world to see if it functions as intended.

I haven't been able to find any obvious pitfalls with the idea though, hence I shared it on this blog. Hope I caught your attention! I encourage all theorists to play around with the idea.
Email me if you find anything wrong with the system, or if you have some unique ideas of your own!

---

[^1]: Even in strongly typed programming languages types can (and will) generalize (HM type systems have generalization rules for this), but this generalization happens only
    under very controllable criteria. For this reason I don't take this under consideration in this blog post.
[^2]: You might be inclined to consider the program counter "state", but at that rate we could classify *everything* inside of a computer as a state change.
    I consider state to be anything within the context of the programming language we're using. The program counter would classify as state if you were writing in assembly, but since it's not exposed
    to us directly it shouldn't be considered state.
[^3]: It is true that the definition of purity entails *no mutations at all*. This definition starts being less applicable in the context of a language with an effect system though, and that's
    why I allowed myself to make such statements :)
