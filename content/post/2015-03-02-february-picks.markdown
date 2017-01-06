---
categories: picks
comments: true
date: 2015-03-02T13:47:59Z
title: February Picks (2)
slug: february-picks
---

"Random picks from all over the Internet".

<!--more-->

## English

### Articles

* [Awk in 20 Minutes](http://ferd.ca/awk-in-20-minutes.html)

  One of the Linux tools I like so much, because it does its job great. If you
  need to analyze some log (or command's output) just once (i.e. you do not
  have an UI for this), this is the right tool.

* [PostgreSQL anti-patterns: read-modify-write cycles](http://blog.2ndquadrant.com/postgresql-anti-patterns-read-modify-write-cycles/)

  Article shows one of DB's anti-patterns: read-modify-write cycle, which you
  should avoid, if possible, or use other options (row level locking, use of
  SERIALIZABLE transactions, etc.).

* [Streaming Big Data: Storm, Spark and Samza](http://www.javacodegeeks.com/2015/02/streaming-big-data-storm-spark-samza.html)

  If you are starting to learn about all this big data stuff and want to hop on
  a train, here is a very nice intro to the current data streaming solutions:
  Apache Storm, Spark and Samza.

* [STREAM PROCESSING, EVENT SOURCING, REACTIVE, CEP… AND MAKING SENSE OF IT ALL](http://blog.confluent.io/2015/01/29/making-sense-of-stream-processing/)

  "People in different fields use different vocabulary to refer to the same
  thing. I think this is mainly because the techniques originated in different
  communities of people, and people seem to often stick within their own
  community and not look at what their neighbours are doing."

### Videos

* [Call Me Maybe: Carly Rae Jepsen and the Perils of Network Partitions - RICON East 2013](https://www.youtube.com/watch?v=mxdpqr-loyA)

  This is kind of an old talk and many things probably were fixed by now. Still
  I found it very interesting and funny. Kyle Kingsbury (https://aphyr.com/)
  shows how some DBs (Redis, MongoDB, PostgreSQL, Riak) behave in case of
  network partition.

* [Onyx: Distributed Workflows for Dynamic Systems by Michael Drogalis](https://www.youtube.com/watch?v=vG47Gui3hYE)

  Onyx is a new distributed computation system written in Clojure, which has a
  pair of distinctive features. For example, it allows you configure input,
  output and transformations in runtime.

## На русском

### Статьи

* [Балансировка нагрузки: основные алгоритмы и методы](http://blog.selectel.ru/balansirovka-nagruzki-osnovnye-algoritmy-i-metody/)

  Коротко и полезно об основных видах и алгоритмах для балансировки нагрузки.
