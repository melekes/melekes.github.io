---
tags:
- talks
- programming
comments: true
date: 2015-12-13T10:16:59Z
title: The Best of RICON 2015
slug: the-best-of-ricon-2015
---

[RICON](http://www.ricon.io/index.html) is all about distributed systems. There
are a lot of academic (Phd) talks and a few practical ones. I've chosen 3 out
of 37 videos, which I liked the most. Hope you'll enjoy these too. _Disclaimer:
your experience may vary._

<!--more-->

# 1. Dynamiq - An implementation of a fanout / queue on top of Riak

by Sean Kelly, Tapjoy (47 min)

<iframe width="560" height="315" src="https://www.youtube.com/embed/KKk_je4GCqs" frameborder="0" allowfullscreen></iframe>

In his talk, Sean explains why they have decided to write their own queue and
not to use existing solutions (such as NSQ or Kafka). After that he presents
the result and lessons they have learned on the way.

# 2. Writing distributed systems is hard

by Ben Hindman, Founder Mesosphere, Inc. (1 hour 2 min)

<iframe width="560" height="315" src="https://www.youtube.com/embed/K76WZkkBO2c" frameborder="0" allowfullscreen></iframe>

# 3. Distributed Transactions - The Fairness Isolation Throughput Tradeoff

by Jose Faleiro, Yale University (45 min)

<iframe width="560" height="315" src="https://www.youtube.com/embed/5GvvkmrKKrM" frameborder="0" allowfullscreen></iframe>

*WARNING: his English is not perfect*. But if you're interested in distributed
transactions (in DBs) - must watch.

[The good news](https://youtu.be/N2472uS5Y6M?t=17m31s) from Uber: they are getting out of HTTP + Json business because:

- HTTP is slow, complex, and inconsistent
- JSON is hard to validate, awkward in non-node
- Thrift is ok, but generated code is bad

That's why they wrote https://github.com/uber/thriftrw-node and
https://github.com/uber/thriftrw-python libraries.

Also there are some [great lessons](https://youtu.be/GT8JbaRyrsc?t=28m34s) from Noah Gift:

- ORMs are just horrible
- Really do take backups seriously
- Erlang and Riak are really good combination
- Be ok with constantly failing in every way possible: Hiring, Software, Product Market fit, Technology

