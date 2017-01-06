---
tags:
- ruby
- erlang
comments: true
date: 2015-08-03T15:09:10Z
title: From Ruby To Erlang. Beginner's mistakes
slug: from-ruby-to-erlang
---

I've  been programming full-time using Erlang for a while already (about eight
months or so). Before Erlang, I was doing some hardcore Ruby. Obviously, these
are very different languages: OOP vs functional, mutable vs immutable and so
on. Also, there are things you won't find in Ruby (the opposite is also true).

In this post I want to show you the mistakes that I've made and the lessons
that I've learned during the transition.

<!--more-->

## 1. List Comprehensions

There is no such thing as List Comprehension in Ruby (but you could write
[something similar][1]), so when I was using it in Erlang, I didn't fully
understand how it works. Let me show you.

```erlang
[X || X <- [1,2,3,4,5,6], X > 3].
=> [4,5,6]
```

There are 3 main components here:

1. `X <- [1,2,3,4,5,6]` - **generator** - usually some set of elements;
2. `X > 3` - **filter** - conditions, that we impose on these elements;
3. `X` - **list** - expression, which gives us the resulting element.

<img class="img-rounded" src="/images/posts/2015-08-03-from-ruby-to-erlang/listc1.png" alt=""/ width="100%" title="">

I thought that, the way it works is "one by one":

1. element is taken from generator;
2. if it passes all the filters, the expression on the left gets executed;
   otherwise, goto (1).

As it turned out, I was wrong. I've noticed it, when I wrote a for loop using
list comprehension, and, later on, one of the filters fell.

```erlang
[save(Rec, Db) || Rec <- Records, is_dirty(Rec), can_be_saved(Rec)]
```
*this is not the production code*

What do you think will happen if `can_be_saved` throw an error for the
third record? **Correct answer**: non of the records will be saved.

<img class="img-rounded" src="/images/posts/2015-08-03-from-ruby-to-erlang/listc2.png" alt=""/ width="100%" title="">

<img class="img-rounded" src="/images/posts/2015-08-03-from-ruby-to-erlang/listc3.png" alt=""/ width="100%" title="">

The way it works is "one by one || one by one": firstly, Erlang generates and
filters initial list. After that, it executes expression on the left side for
each item resulting in a new list.

**Lesson #1. List Comprehension should not be used when you need a for loop. Instead, use recursion.**

```erlang
save_records([], _) -> ok;
save_records([Rec|Rest], Db) ->
    try
        case is_dirty(Rec) of
            false -> throw({filtered, io_lib:format("~p not dirty", [Rec])});
            true -> ok
        end,
        case can_be_saved(Rec) of
            false -> throw({filtered, io_lib:format("~p cannot be saved", [Rec])});
            true -> ok
        end
    of _ ->
        save(Rec, Db)
    catch
        throw:{filtered, Reason} -> lager:debug(Reason)
    end,
    save_records(Rest, Db).
```

This way, if `can_be_saved` does throw an error, at least some of the records
will be saved.

## 2. Lager

[lager](https://github.com/basho/lager) is a logging framework for Erlang and
it has become a de facto standard for Erlang applications.

Usually, when you look through log files in Ruby (e.g. puma.log), you can say
"we started processing at XXX and finished at YYY" and it will be more or less
accurate.

```
I, [2015-04-31T03:04:20.613116 #28143]  INFO -- : Started
...
I, [2015-04-31T03:04:21.345985 #28143]  INFO -- : Finished
```

So the first thing I did, when I needed to find a bottleneck in one part of our
system, was looking at log timings. Wrong move!

```
2015-05-25 16:50:42.229 [info] Started
2015-05-25 16:50:42.235 [info] Finished
```

6ms - wow!

It is like an old shabby van with free candies. You have a feeling that
something is not right.

And when I had used `timer:tc` (analog in Ruby - `Benchmark`), these timings
proved to be "wrong". And that's because in Erlang, logger (as most things) is
a separate process with its own mailbox. What you see are **the times of when
it received the messages**. In contrast, things are usually happening in the
same thread in Ruby (that is why timings are usually more accurate).

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-08-03-from-ruby-to-erlang/lager1.png" alt=""/ width="100%" title="">
</div>

**Lesson #2. Do not rely on lager timings, because it is a separate gen_server (i.e. you don’t know when it will process your messages).**

## 3. High-loaded gen_server

This is more like a word of advice. When you have a `gen_server`, which is
supposed to process, say, 1000 events per second, you can't make any
synchronous blocking calls (e.g. to Redis) or set any locks, because soon
enough the process mailbox will be full of messages and things will become
ugly.

What you should do instead, is to spawn a process per unit (an order or
something like that) or use a worker pool ([1][3],[2][4],[3][5]). I personally
recommend to watch [this talk][2] by Anthony Molinaro at Erlang Factory SF
2015, where he compares a few different options we have at the moment.


If you also had some troubles during transition to another language, let me
know. I personally laugh at such moments and don't take them too seriously,
because, you know, it just happens sometimes. The important is to learn by
these mistakes.

[1]: http://blog.tarkalabs.com/2015/04/21/list-comprehension-in-ruby/
[2]: https://www.youtube.com/watch?v=GO_97_6w5lU
[3]: https://github.com/devinus/poolboy
[4]: https://github.com/seth/pooler
[5]: https://github.com/inaka/worker_pool
