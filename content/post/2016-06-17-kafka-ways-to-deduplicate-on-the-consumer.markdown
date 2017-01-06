---
categories:
- kafka
- distributed-systems
comments: true
date: 2016-06-17T14:41:32Z
published: false
title: 'Kafka: дедупликация на стороне потребителя'
slug: kafka-ways-to-deduplicate-on-the-consumer
---

Допустим, вам понадобилось читать сообщения из Kafka и обрабатывать каждое
только один раз ("exactly one processing").

В FAQ Kafka написано:

{% blockquote %}
Include a primary key (UUID or something) in the message and deduplicate on the consumer.
{% endblockquote %}

https://cwiki.apache.org/confluence/display/KAFKA/FAQ#FAQ-HowdoIgetexactly-oncemessagingfromKafka?

Но что это значит? Что может выступать в роли первичного ключа? И какие вообще
у меня есть варианты?

<!--more-->

## Отступление

Сразу оговорюсь, что **мало разбираюсь в данном вопросе** и то, что вы увидите
ниже, лишь моя попытка обобщить найденное и записать свои мысли. Поэтому,
**если вы разбираетесь в этой теме, пожалуйста [зайдите сюда][docs]** или оставьте
комментарий.

Ещё стоит отметить, что доставка 1 сообщения 1 раз ("exactly once delivery")
невозможна впринципе (см.
https://lobste.rs/s/ecjfcm/why_is_exactly-once_messaging_not_possible_in_a_distributed_queue/comments/e5qcdf#c_e5qcdf).

## Ситуация

И так, у нас есть Kafka, настроенная на доставку по крайней мере 1 раз ("at
least once delivery") и потребитель, который вычитывает сообщения из топика и
коммитит оффсет после успешной их обработки.

Для простоты будем считать, что у нас 1 потребитель, а не группа.

Дублирование сообщений происходит когда потребитель падает и неуспевает
закоммитить оффсет. Когда он поднимается снова, он прочитает несколько уже
обработанных сообщений (начиная с позиции последнего сохраненного оффсета).

## Варианты

Как определяем уникальность:

1. Либо по данным в сообщении (тот самый UUID, другие варианты)
2. Либо по topic/partition/offset

Как избежать повторной обработки:

1. Хранить topic/partition/offset вместе с данными и коммитить их в 1 транзакции
2. Уникальный индекс на данные в сообщении
3. Сделать обработку идемпотентной

Пункты 1 и 2 не обязательно подразумевают использование БД (важно, чтобы были
транзакции - пусть даже двухфазные). У LinkedIn есть библиотека
https://github.com/linkedin/gobblin, в которой оффсет и данные льются в HDFS.

Ссылки:

- https://kafka.apache.org/documentation.html#semantics
- http://bravenewgeek.com/you-cannot-have-exactly-once-delivery/
- http://ben.kirw.in/2014/11/28/kafka-patterns/

[docs]:
