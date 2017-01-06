---
categories:
- books
- erlang
comments: true
date: 2015-05-23T15:35:04Z
title: 'Заметки на полях: Программирование в Erlang'
slug: zamietki-na-poliakh-proghrammirovaniie-v-erlang
---

Решил начать новую серию постов. Каждая статья будет представлять из себя набор
советов, инструментов, скриптов или просто умных мыслей из определенной книги.
Читать книгу или нет? Это решать вам самим.

<!--more-->

<img class="img-rounded" src="/images/posts/2015-05-23-zamietki-na-poliakh-proghrammirovaniie-v-erlang/book.jpg" alt=""/ width="304" title="Программирование в Erlang">

Вот что советуют Франческо Чезарини и Симон Томпсон в своей книге ["Программирование в Erlang"][1]:

- не меняйте приоритет процессу (за редким исключением, когда вы точно понимаете что делаете и зачем);
- не пропускайте сообщения в receive;
- не увлекайтесь =/= и =:= (равенство с проверкой по типу) - они засоряют код;
- создавайте процесс на "сущность" (например, сообщение, входящий файл);
- используйте spawn_link и spawn_monitor, а не `link(spawn(...))` - первые атомарны;
- не копируйте MaxR / MaxT из модуля в модуль - их нужно выбирать с умом (http://www.erlang.org/doc/man/supervisor.html);
- используйте circuit breakers (https://github.com/jlouis/fuse, https://github.com/klarna/circuit_breaker);
- не используйте infinity;
- `file:write("/tmp/procs.txt", erlang:system_info(procs))` - дамп информации обо всех процессах;
- не используйте Erlang для передачи больших кусков данных;
- рекомендуется отключать swap (лучше, чтобы сразу все свалилось).

[1]: http://www.ozon.ru/context/detail/id/30671701/?partner=akalyaev
