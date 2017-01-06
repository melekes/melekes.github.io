---
categories:
- programming
comments: true
date: 2015-12-14T15:33:33Z
title: Еще немного про именование переменных
slug: a-little-more-on-variable-naming
---

Вообще, после того, как вы прочитаете "Совершенный код" Стива Макконнелла,
вопросов как назвать ту или иную переменную быть не должно. Но есть некоторые
моменты, которые не освещены в книге и нуждаются в обсуждении.

<!--more-->

## Меры (ms, min)

Недавно пришлось залезть в исходники HBase, чтобы выяснить в каких единицах мне
нужно задать TTL. В документации я этого не нашел :( Вот, например, одна строка из теста:

```java
protected static final int TTL = 86400;
```
<small>(https://github.com/apache/hbase/blob/a545d71295e582398b2689ed09d2167d7f118cec/hbase-rest/src/test/java/org/apache/hadoop/hbase/rest/model/TestColumnSchemaModel.java#L35)</small>

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-12-14-a-little-more-on-variable-naming/wtf.png" alt="" width="100%" title=""/>
</div>

Что это? Минуты, секунды, миллисекунды? Как я должен понять это?

Какие варианты я вижу:

1. Писать единицы в названии: `TTL_IN_SEC` - так себе, думаю тут все согласны.
2. Писать рядом комментарий: `TTL = 86400; // sec` - уже лучше, но ненамного; пока придерживаюсь этого варианта.
3. Использовать структуры языка: `-define(TTL, {86400, sec});`.
   Для тех, кто не знает, это определение константы в Erlang'e. Здесь мы
   складываем значение и единицу в кортеж (tuple). Очевидный минус в том, что
   нужно будет переписать код для работы с ними.
4. Предоставить стандартный класс, кот. явно задает единицу измерения для любых
   промежутков времени и методы для преобразования одних единиц в другие. К
   примеру, [time](https://golang.org/pkg/time) в Golang:

```go
func Sleep(d Duration)

type Duration int64
const (
  Nanosecond  Duration = 1
  Microsecond          = 1000 * Nanosecond
  Millisecond          = 1000 * Microsecond
  Second               = 1000 * Millisecond
  Minute               = 60 * Second
  Hour                 = 60 * Minute
)

// example
time.Sleep(time.Second * 2)
```

В Ruby есть библиотека [ActiveSupport](http://api.rubyonrails.org/v2.3/classes/ActiveSupport/CoreExtensions/Numeric/Time.html):

```
TTL = 20.seconds
```

Кстати, TTL для отдельного столбца [задается в
мс](https://github.com/apache/hbase/blob/master/hbase-client/src/main/java/org/apache/hadoop/hbase/client/Mutation.java#L444).
В примере выше оказались секунды.

## Переменные под прикрытием

Зачастую вижу в коде в одном месте переменная называется `list_id`, а в функции
куда она передается - `dest_id`.

```
# first_class.rb
list_id = 1
call(list_id, ...)

# second_class.rb
def call(dest_id)
  ...
end
```

Плохо, что при этом теряется частичка смысла. Глядя на код во втором случае, мы
уже не знаем ID чего передается в функцию. Нам приходится вспоминать, или
строить догадки, или возвращаться в то место, где происходит вызов функции
(`first_class.rb`).

За этим однозначно нужно следить. В нашем примере можно было обозвать
переменную `dest_list_id` в `second_class.rb`.

Похожую мысль в своем [ЖЖ](http://tonsky.livejournal.com/304954.html) недавно
высказал [Никита Прокопов](https://twitter.com/nikitonsky).

## Какой тип?

В языках со строгой типизацией (в частности, в Erlang) мы получим ошибку в
рантайме, если попытаемся склеить число со списком:

```
1 ++ "abc".
** exception error: bad argument
     in operator  ++/2
        called as 1 ++ "abc"
```

потому что отсутствует автоматическое приведение типов. Проблема тут в том, что
ты не можешь узнать тип переменной исходя из ее имени:

```
call(ListId,...) ->
  Str = integer_to_list(ListId),
  ...
```

сюда в результате рефакторинга может прийти строка и все попадает нафиг.

Опытным путем было установлено, что добавление типа к имени переменной помогает
избегать подобных багов.


```
call(ListIdStr,...) ->
  ...
```

Еще конечно выручает [dialyzer](http://www.erlang.org/doc/man/dialyzer.html)
или его аналоги: [PyContracts](https://andreacensi.github.io/contracts/),
[Typed Clojure](http://typedclojure.org/). Ну или статическая типизация.

Если у вас есть замечания или дополнения, welcome to комментарии.
