---
tags: picks
comments: false
date: 2015-01-06T12:19:19Z
title: January picks
slug: january-picks
---

"Random picks from all over the Internet".

<!--more-->

## English

### Articles

* [The Tao of HashiCorp by Mitchell Hashimoto, Armon Dadgar](https://hashicorp.com/blog/tao-of-hashicorp.html)

  If you are looking some very good principles for your team or organization,
  these from HashiCorp may give you the foundation.

* [On-Disk Microbenchmark](http://symas.com/mdb/ondisk/)

  Nice benchmarks of LMDB, BerkeleyDB, Google LevelDB and 3 of its derivatives -
  Basho LevelDB, HyperLevelDB, and Facebook's RocksDB, as well as TokuDB and
  WiredTiger. Worth seeing.

* [Strong consistency models](https://aphyr.com/posts/313-strong-consistency-models)

  Well written article about program correctness and different strong
  consistency models and how they fit together.

### Videos

* [What We Actually Know About Software Development, and Why We Believe It's True by Greg Wilson](http://vimeo.com/9270320)

  When someone comes to you and says "I want to learn Haskell, because parallel
  programming is so easy in it" I want you to say "Where is the evidence? Has
  somebody tested it? Do we trust them?" Thoughtful talk on the software
  development.

### Tools

Do you want to improve life of your Linux laptop's battery? Here is a handy tool - [tlp](http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html).

```
sudo add-apt-repository ppa:linrunner/tlp
sudo apt-get update
sudo apt-get install tlp tlp-rdw
```

ThinkPads require an additional:

```
sudo apt-get install tp-smapi-dkms acpi-call-dkms
```

## Russian

### Презентации с Higload 2014

* [Асинхронная репликация без цензуры: архитектурные проблемы MySQL, или почему PostgreSQL завоюет мир, Олег Царёв](http://www.slideshare.net/tsarevoleg/ss-40969331)

  Всё что вы хотели знать про репликацию, но боялись спросить. Ещё один
  отличный доклад с Highload 2014.

* [Клиентские приложения под нагрузкой и Анатомия веб-сервиса 2.0, Андрей Смирнов](http://smira.ru/posts/highload-2014.html)

  Пара презентаций от Андрея Смирнова о проблемах клиент-серверных приложений и
  возможных подходах к построению backend’а.

