---
tags:
- redis
- linux
- networking
comments: true
date: 2015-10-19T14:00:26Z
title: Redis дропает события? Что?
slug: redis-dropaiet-sobytiia-chto
---

"Redis дропает события? Что?" или поучительная история о том, как важно читать
документацию.

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-10-19-redis-dropaiet-sobytiia-chto/docs.jpg" alt="" width="100%" title=""/>
</div>

<br/>

<!--more-->

В один дождливый и прохладный осенний день мы увидели слишком маленькое
значение одной из метрик нашего приложения. Оно занималось (1) отправкой
текстовых сообщений через специальный шлюз и приемом отчетов о доставке. Отчеты
(2) публиковались в Redis через Redis Pub/Sub и (3) вычитывались отдельным
демоном (Listener), который (4) отмечал факт получения или неполучения
абонентом смс в БД (Postgresql).

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-10-19-redis-dropaiet-sobytiia-chto/app.png" alt="" style="width:400px;" title=""/>
</div>

В статистике значилось: **"отправлено 20000, доставлено 122"**. По необъяснимой
причине мы недополучали большую часть отчетов.

Сначала я предположил, что они просто не доходят до Redis, но посмотрев логи
убедился в обратном. Далее подозрение пало на Listener и мой тимлид высказал
предположение о том, что он (Listener) не успевает вычитывать все публикуемые
события и **Redis их дропает**.

Увидев в логе Redis строчку "Client XXX scheduled  to  be  closed  ASAP  for
overcoming  of  output  buffer  limits", мы поняли что скорее всего так и есть.

Я был удивлен. Опыта работы с Redis у меня было не так уж и много, но мне все
равно казалось это нереальным.

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-10-19-redis-dropaiet-sobytiia-chto/wat.png" alt="" style="width:400px;" title=""/>
</div>

<br/>

Думалось, что он будет хранить данные в списке так долго как сможет.
Оказывается, Redis Pub/Sub вообще не хранит никаких данных (есть буфер). В
идеале, он старается раскидать данные с сокета "издателя" (Publisher's socket)
по сокетам подписчиков (Subscribers sockets) на одной итерации [event loop][1].

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-10-19-redis-dropaiet-sobytiia-chto/pub-sub.png" alt="" style="width:450px;" title=""/>
</div>

Так что же про буферы. У Redis есть буфер с soft limit = 8MB и hard limit =
32MB. Также есть по 1 буферу на каждое TCP соединение.

Размеры буферов можно узнать так:

```
$ cat /proc/sys/net/ipv4/tcp_rmem # publisher's socket
$ cat /proc/sys/net/ipv4/tcp_wmem # subscribers sockets
```

В нашем случае размер и того, и другого = 4MB.

Если подписчик не успевает вычитывать данные, буфер справа в какой-то момент
заполнится и TCP запретит дальнейшую запись в него. Redis пометит буфер как
"non-writable" и начнет заполнять свой буфер.

Если размер буфера Redis'а превысит 32MB или в течении 60 секунд будет больше
8MB, то Redis закроет соединение. Об этом честно написано в [документации
Redis](http://redis.io/topics/clients) см. "Output buffers limits". Правда,
нигде не написано, что перед тем как соединение будет закрыто часть сообщений
будут потеряны.

В нашем случае Redis действительно закрывал соединение, но Listener
переподнимался Upstart'ом и тут же подписывался заново, продолжая выгребать
лишь часть отчетов.

Описывать как мы поправили эту багу не буду, ибо это уже не так интересно для
читателя. Вывод для себя сделал такой - **перед тем как использовать
инструмент, прочитай документацию**. В серьезных продуктах обычно расписано
все, включая разнообразные [corner case][2].

[1]: https://en.wikipedia.org/wiki/Event_loop
[2]: https://en.wikipedia.org/wiki/Corner_case
