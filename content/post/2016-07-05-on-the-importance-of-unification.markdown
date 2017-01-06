---
tags:
- programming
comments: true
date: 2016-07-05T16:24:36Z
title: On the importance of unification
twitter_card:
  image: http://homeonrails.com/images/posts/2016-07-05-on-the-importance-of-unification/hammer.png
  type: summary_large_image
slug: on-the-importance-of-unification
---

Unification, for me, means having one way or instrument (not always the best)
to deal with a problem. And, in some cases, it is crucial.

<img class="img-rounded" src="/images/posts/2016-07-05-on-the-importance-of-unification/hammer.png" alt="It's important to have only one instrument for solving a problem." width="100%" title=""/>

<!--more-->

## Example #1

Let's look at the design of the Go programming language. In one of my favorite
talks, "Simplicity is Complicated", Rob Pike says: "A lot of people have asked
for things like map and filter to be built into Go and we said no". He gave
  this example while talking about the expense feature(s) may have, but I think
  it also applies to the quote below.

{% blockquote Rob Pike %}
If there is a lot of features, you may look at the line of code, write it one
way. "Uu, I could do something different." You might even spend half an hour
playing with a few lines of code... and it's kind of a waste of time to do it,
but worse, when you come back to the program later, you have to recreate that
thought process.

Preferable to have just one way, or at least fewer, simpler ways.
{% endblockquote %}

<iframe width="560" height="315" src="https://www.youtube.com/embed/rFejpH_tAHM" frameborder="0" allowfullscreen></iframe>

Highly recommend watching this video.

## Example #2

At FunBox, the company I was working for, we had only one way to deploy the
code - [Capistrano](https://github.com/capistrano/capistrano).

We were using many languages (Ruby, Erlang, Clojure, Elixir). Each of those was
packaged differently (raw, release, .tar, release), but there was only one
deploy method. And it was great! **You, as the programmer, do not think how to
deploy a project**, you simply type `bundle exec cap production deploy`.

Capistrano itself may not be the best choice, but it's not so important,
comparing to what we're talking about.

## Example #3

Another example may be using [make](http://linux.die.net/man/1/make) as a build
tool for all of your projects. Again, if you have many languages (e.g.
JavaScript on the frontend and Go on the backend), the cost of having 2
different ways to test/build/etc. may be too high. To ease the development, you
could create a Makefile and have a single target for testing (say, `make
test`).

If you have any comments, you could leave them below or send me an email.
