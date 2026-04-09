---
title: "Our Calendar Sucks"
description: "It's the 20th March, 4:02.09.1 CET. Wait, that doesn't sound right."
pubDatetime: 2026-04-09
tags:
  - misc
draft: false
---

... oh you thought I was talking about some calendar app? No, we're going all in.

## The Gregorian Calendar

You and I probably know the Gregorian Calendar perfectly well -- 365 days a
year, leap year every 4 years. 12 months, 24 hours in a day.

January and February exist at the whim of a Roman ruler. Months are sometimes 30 days long,
sometimes 31, sometimes 28, sometimes 29.

Leap years happen every 4 years unless the year is divisible by 400 (sure).
The year begins on January 1st, yet again on a whim. There is no great astronomical event at that time, it just happens to start the year.

Okay, at least all these systems exist to make our timekeeping nice and accurate, right? Wrong. Even with leap years the calendar drifts
by 1 day every ~3,300 years.

So here's a cool question: what if we disregarded familiarity entirely and tried developing a new system from scratch? What would that look like?

## Starting from Scratch

Before starting this adventure I thought it'd be wise to look at other calendar attempts. To be completely honest, there's only one really worth
discussing: [Symmetry454](https://en.wikipedia.org/wiki/Symmetry454).

Symmetry454 works by having every month alternate between a length of 4 weeks and 5. This keeps month lengths pretty consistent but requires
a **whole leap week** every 5 to 6 years. Not one day, a whole week. I respect the symmetry (pun intended), but looking at its other quirks it's just not my cup of tea really.

I was going to write a whole essay on symmetry454 here, but since this is a blog and not an academic paper I highly encourage you to have a quick look around
prior art for yourself and see how it improves upon the Gregorian calendar, it's worth it! :)

## Design Choices

So, we've established that we don't really like prior art, so what do we do? First, we decide what we want our calendar to actually *do*.
Do we want to prioritize astronomical precision? Do we want to make it easily accessible? Do we want to prioritize solar year precision or lunar precision?
Is the calendar a fixed one or not? Do we want to count years, months, half-days? The sky's the limit.

The hard part is that you can't answer all of these questions at once. Choosing one sacrifices something in the other categories.
My goal is to try and find a sweet spot between "familiar enough" with our existing calendar system as well as mathematical beauty and accuracy as a top priority.
We're going to make a *fixed* calendar and we're going to try to make it as awesome as possible.

### Human Necessities

Think about it, what do humans really need from a calendar? What do we care about the most practically speaking? To me, the most important things are, in order:
1. When the day starts and when it ends (day tracking)
2. When the next season starts (season tracking)
3. When the whole cycle repeats again (year tracking)

Constructs like weeks and especially months are really only social constructs - they do not actually amount to much. So, if we're ever going to be making sacrifices, it should
be in these two things. Days, seasons and yearly precision are a priority.

### Symmetry

If we're rambling on about mathematical symmetry, how do we want to achieve it? Notice that in our calendar system many things rely on multiples of 12.
In this system, I'll be aiming for a base-12 "magic number" that best approximates all the units that we're interested in (a day, a season and a year).

## Deriving the Tick

The biggest complexity for this "magic number" is that it must satisfy multiple divisibility constraints simultaneously.
For simplicity, let's call this number the *tick*. Ideally, we want the tick to:
1. Fit almost perfectly into a year (365.2421897 days)
2. Divide cleanly into seasons
3. Divide cleanly into months
4. Divide cleanly into days

Surely that's impossible, right? Turns out, not at all! There are many numbers that fit these conditions quite well, each with fascinating
tradeoffs. In your spare time, I implore you to write a script that tries to find such numbers.

The most important and fundamental division is the *amount of ticks in one day*. Think about it -- your current clock
has a nice, clean number: 24 hours in a day. We also want to find a tick value that creates a nice subdivision for the day.

I've done a lot of sifting and parsing through the outputs of the various bruteforce scripts I made.
The number we will choose is $13824$ ticks per day. You might be thinking to yourself: "have you lost your mind?? how is that clean?"
Here's where the magic begins.

$$
13824 = 8000_{12}
$$

Our ugly number in base 12 is actually very clean!

Not only that, it's also highly decomposable: $8000_{12} = 8 \times 12 \times
12 \times 12$. This will be useful for when we build our own clock later.

Assuming this number of ticks per day, we can compute the actual length of the tick. We know that a regular day
has 86400 seconds. Therefore:
$$
\frac{86400}{13824} = 6.25 \text{s}
$$

Perfect: now we know that our tick is exactly $6.25$ seconds long. Everything else will follow from this definition.

## Deriving the Year

We know that a tropical year is $365.2421897$ days. From here we calculate the number of ticks in a year:
$$
13824 \text{ ticks/day} \times 365.2421897 \text{ days/year} = 5049108.0304128 \text { ticks/year}
$$

But since we can't have a decimal point in a calendar we trim off the decimal value and treat it as our *error*.
This means, in effect, our calendar year is actually:
$$
\frac{5049108}{13824} = 365.2421875 \text { days/year}
$$

We can now compute the **precision** of our calendar by taking the difference between the real number of days
in a solar year and our precision:
$$
365.2421897 - 365.2421875 = 0.0000022 \text { days lost} = 0.19008 \text { seconds lost}
$$

That's incredibly good! That means that our calendar system needs a leap year once every $454,545$ years.
Friendly reminder that the Gregorian calendar needs a leap year once every 4 years! The difference in precision is
astounding.

## Deriving the Seasons

A year contains four seasons, and our tick value allows us to evenly divide the year into four:
$$
\frac{5049108}{4} = 1262277 \text { ticks/season}
$$

This amounts to $91.310546875$ days per season. This is not that big of a
problem: it just means that a season changes mid-day. This even division means
that the season start/end is sometimes off by up to 2 days from the true
astronomical season, but this is reasonable without introducing dynamic systems
or other complexities.

## Deriving the Months

To derive months, we take each season and divide it into 3. Yet again, our tick value is so magical
that it allows us to perform this divison cleanly:
$$
\frac{1262277}{3} = 420759 \text { ticks/month}
$$

That's approximately $30.4$ days in each month, 12 months in a year. You might
find this one a hard pill to swallow, and we will address this discrepancy
later on with **civil months** -- it's quite obvious that a month shouldn't
take up a fraction of a day.

## Deriving the Day

We've now arrived at deriving the day, more specifically, the clock. The day is divided into the following units:

- 8 **octants**
- 12 **dodecs**
- 12 **subdodecs**
- 12 **ticks**

This division gives us exactly $13824$ ticks per day, which means everything is consistent.

The octants can be thought of as "hours" in our system, although they tick much slower! The 0th octant is midnight,
while the 4th octant is midday.

Surprisingly, in my usage of this calendar in my own private life, I've found these numbers to be crazy intuitive:
- 1 octant is **3 hours**
- 1 dodec is **15 minutes**
- 1 subdodec is **1.25 minutes**
- 1 tick is **6.25 seconds**

Time just seems to fly more naturally now that I've used it for a while, I'm not even joking.

A full time is therefore represented like this: `4:03.02.01`. Usually, you don't need tick-level precision,
so you can say `4:03.02` or even just `4:03`!

## Start of the Year

There are still some things left to discuss about this calendar system, namely the month names
and when the year starts. This one is surprisingly involved, so stay focused!

First of all, I'd like the year to begin on a -- you know -- normal date. For
this reason, I'd like the year to start at the beginning of Spring. For this to
make sense, we need a known, accurate reading of the vernal equinox. As it
turns out, the year 2000 had such an accurate scientific reading!

This means that the first day of the year in this calendar -- March 1st -- is
actually the vernal equinox measurement from the year 2000 -- 7:35, March 20th
2000 UTC.

However, if we made our midnight 7:35 in regular calendar time, we'd have some problems -- the 0th octant
would no longer represent midnight, and the 4th octant wouldn't represent midday. For this reason, we anchor
March 1st to 0:00, March 20th 2000 UTC our time.

The side effect of this is that the year is currently $26$, not $2026$. Oh
well! Not that hard to convert between both systems.

### Month Naming

Because the year starts on March, we need some new names for the 11th and 12th months. Here is the list of months
in Dodecalendrium:
1. March
2. April
3. May
4. June
5. July
6. August
7. September
8. October
9. November
10. December
11. Undecember
12. Duodecember

If you have a more clever name, perhaps derived from some old English roots, send me a message!

## Weeks

Since weeks are a human construct, they are trivially tacked on to the existing calendar system.
Monday starts exactly on March 1st, Year 0. Count up in 7-large increments from there, and you have your
current weekday :)

## Dodecalendrium

Altogether, all of these systems make up the modern Dodecalendrium calendar:

1. 8-octant days
2. 12 months, starting from March
3. 4 seasons
4. An extremely accurate solar year

## Civil Months

Let's address the biggest pain point -- currently months take up 30.4 days. This means that a change from March
to April can happen in the middle of the day. For convenience, we introduce **civil months**, which work exactly
like our existing months, just simpler.

A civil month rounds up to the nearest midnight. This means a civil month will either have 30 or 31 days depending
on the rounding error.

This allows us to easily track time as humans without having to worry about a month being halfway throughout a day.

## Implementations

At some point I would like to share some implementations and visualizations of the calendar. I do have some personal projects
like an Android app and a Rust conversion CLI, but both of these projects were entirely vibe-coded to save me time and probably aren't
worth releasing. I encourage any interested party to develop tooling for this novel time-tracking system!

## Conclusion

In this post I showcased a novel calendar implementation based on a single, fundamental tick value (6.25s).
It maintains some goodies of our Gregorian calendar while drastically improving precision and coherence.

There is one caveat I've been unable to fix yet with this system -- whether I should keep civil months or not.
When they exist, you get problems, because a year isn't perfectly divisible into our concept of days, and so New Years
always lands on an odd number. If I remove civil months, then months can tick over halfway through a day, which might
make timekeeping slightly more complicated. If you have ideas, let me know!

## Extra Information

Skip this if you're not a nerd.

I've tried to do as much research as I could as a programmer and mathematician at heart,
but I'm not an astronomer at the end of the day. If you have any improvements please email me at vhyrro@gmail.com :)

Now, there are 100 and one ways to build a calendar, so I'd like to be more precise at what I mean by "better". First of all, I'm not designing
something that aims to be familiar to the current calendar system. I am not at all expecting any level of adoption, but rather I consider this
to be a great experiment of "what if we just ignored human wonts and tried to make something more symmetrical".

I wanted this calendar to prioritize mean solar year precision while maintaining a high level of mathematical symmetry. This is a fixed calendar
so tradeoffs are always going to be present.
Improvements to symmetry and mean solar year precision are the main benefits of this system and what I mean by "better".
For calendars emphasizing lunar alignment, see the [International Fixed Calendar](https://en.wikipedia.org/wiki/International_Fixed_Calendar).
