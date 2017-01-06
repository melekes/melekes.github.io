---
tags:
- talks
- ruby-on-rails
- api
comments: true
date: 2014-03-09T13:00:00Z
title: Fast Rails API
slug: fast-rails-api
---

Here are the slides from my internal talk, which I recently gave for my
colleagues.

They are showing the history of optimizing Rails API, starting from AR connections pool and
ending by using Fragment caching. Also there is list of tools for
profiling applications (stackprof, etc.). All techniques are quite
famous.

<!--more-->

<script async="true" class="speakerdeck-embed" data-id="b618391085100131b8c566a463623da4" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js">       </script>

&nbsp;

## What we've tried

1. Connection pool
   * [Concurrency and Database Connections in Ruby with ActiveRecord](https://devcenter.heroku.com/articles/concurrency-and-database-connections)
2. [Rails-api](https://github.com/rails-api/rails-api)
3. Do not load `rails/all`
4. Establish DB connection after fork/new thread was created
5. [Unicorn worker killer](https://github.com/kzk/unicorn-worker-killer)
6. Postgresql tuning
   * [Работа с PostgreSQL: настройка и масштабирование Алексея Васильева](http://postgresql.leopard.in.ua/html/)
   * [PostgreSQL Hardware Performance Tuning by Bruce Momjian](http://momjian.us/main/writings/pgsql/hw_performance/)
   * [Caching in PostgreSQL](http://raghavt.blogspot.ru/2012/04/caching-in-postgresql.html)
7. Rails 4
8. Ruby 2.1.0
9. Fragment caching
   * [Caching Strategies for Rails](https://devcenter.heroku.com/articles/caching-strategies)
   * [How key-based cache expiration works](http://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
10. [Active Model Serializers](https://github.com/rails-api/active_model_serializers)
11. [Oj](https://github.com/ohler55/oj)
12. Do not instantiate AR objects
    * [Lightning JSON in Rails](http://brainspec.com/blog/2012/09/28/lightning-json-in-rails/)
13. Try [OOBGC - Out-of-Band GC](https://github.com/tmm1/gctools)
14. Try different web server (e.g. Puma)

If we missed something, please share your ideas in comments.

## Profiling tools

1. [Stackprof](https://github.com/tmm1/stackprof)
2. [Rack Mini Profiler](https://github.com/miniprofiler/rack-mini-profiler)
3. [Bullet](https://github.com/flyerhzm/bullet)
4. [Request log analyzer](https://github.com/wvanbergen/request-log-analyzer)
5. [NewRelic](http://newrelic.com/)

On the penultimate slide is the title slide of the [presentation](http://www.slideshare.net/maxlapshin/rails-26416461) of Max
Lapshin, which briefly tells that to solve certain problems (such as when you need to
keep a large number of clients) more appropriate solution might be using
another technologies/languages (Erlang in particular).

UPD. Ideas from comments

15. Try [Conditional Get](http://api.rubyonrails.org/classes/ActionController/ConditionalGet.html)
