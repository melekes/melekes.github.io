---
tags:
- erlang
- hbase
- thrift
comments: true
date: 2015-05-23T13:30:47Z
title: Erlang, HBase и Thrift
slug: erlang-hbase-and-thrift
---

И так, вы планируете читать и писать данные в HBase таблицу из Erlang'а. Что ж,
начнем с того, что клиента для Erlang'а нет :( А на выбор имеются:

1. REST
2. Thrift
3. C/C++ Apache HBase Client

<!--more-->

Истории ради отмечу, что когда-то, давным давно, был шлюз для [Avro][1]. Но в
начале 2013 он канул в лету.

{% blockquote http://comments.gmane.org/gmane.comp.java.hadoop.hbase.user/32617 %}
We removed the Avro gateway because the implementation as contributed was a work in progress that was not subsequently maintained.
{% endblockquote %}

Третья опция отпадает, потому как ссылка битая - [см. официальную
документацию][2]. Видимо, в Facebook решили прекратить поддержку этого клиента.
Тем более, по [словам пользователя stackoverflow][3], под капотом он (клиент)
вызывал Thrift API. А еще один уровень нам ни к чему.

Таким образом, остаются REST и Thrift.

Rest
====

[Stargate][4] (REST сервер) поддерживает 3 формата передачи данных - XML, JSON
и protobufs. В целом он выглядит довольно симпатично, но а) проигрывает
thrift'у по скорости (особенно xml и json, которые тащат за собой схему) б)
могут отсутствовать некоторые параметры для требуемого вам метода.

<img class="img-rounded" src="/images/posts/2015-05-16-erlang-hbase-and-thrift/thrift-vs-rest1.png" alt=""/ width="450" title="Program completion time (in seconds)">
<small>
(Program completion time (in seconds) <a href="http://blog.cloudera.com/blog/2014/04/how-to-use-the-hbase-thrift-interface-part-3-using-scans/" target="_blank">http://blog.cloudera.com/blog/2014/04/how-to-use-the-hbase-thrift-interface-part-3-using-scans/</a>)
</small>

Например, в protobuf схеме вы не найдете `filter`, которые может быть нужен при выполнении `Scan`.

```proto
message Scanner {
  optional bytes startRow = 1;
  optional bytes endRow = 2;
  repeated bytes columns = 3;
  optional int32 batch = 4;
  optional int64 startTime = 5;
  optional int64 endTime = 6;
}
```

Хотя в XML схеме он присутствует:

```xml
<complexType name="Scanner">
    ...
    <sequence>
        <element name="filter" type="string" minOccurs="0" maxOccurs="1"></element>
    </sequence>
    <attribute name="startRow" type="base64Binary"></attribute>
    <attribute name="endRow" type="base64Binary"></attribute>
    ...
</complexType>
```

Если скорость для вас не критична, можно смело выбирать REST (REST плюс
protobufs может быть неплохим выбором). Хотя, лучше перед этим убедиться, что
все требуемые параметры (для ваших запросов) присутствуют и проблем здесь не
возникнет.

Thrift
======

У Thrift 2 недостатка:

1. [документации](https://thrift.apache.org/lib/erl) считай нет
2. выглядит он ужасно (просьба любителей прекрасного кода на время
   просмотра запастись успокоительными средствами)

Давайте рассмотрим типовые операции при работе с HBase.

Для начала создадим тестовую табличку:

    $ ~/hbase/bin/hbase shell
    ...
    hbase(main):001:0> create 'users', 'data'
    hbase(main):007:0> put 'users', 'mike', 'data:age', 15
    hbase(main):007:0> put 'users', 'mike', 'data:sex', 'male'
    hbase(main):007:0> put 'users', 'caleb', 'data:age', 21
    hbase(main):007:0> put 'users', 'caleb', 'data:sex', 'male'

### Get

```erlang
{ok, C0} = thrift_client_util:new("localhost", 9090, hbase_thrift, [{connect_timeout, 5000}]),
{C1, {ok, Results}} = thrift_client:call(C0, getRowWithColumns, ["users", "mike", ["data:age", "data:sex"], dict:new()]),
=> [{'TRowResult',<<"mike">>,
               {dict,2,16,16,8,80,48,
                     {[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]},
                     \{\{[],[],
                       [[<<"data:sex">>|{'TCell',<<"male">>,1432370741107}]],
                       [],[],[],[],[],[],[],[],[],[],[],[],...\}\}},
               undefined}]
thrift_client:close(C1).
```

В первой строке мы устанавливаем соединение. Стоит обратить внимание на 2 вещи:
connect_timeout - таймаут на соединение, и hbase_thrift - имя нашего приложения
(обычно == OTP application name). Далее мы забираем строку с интересующими нас
столбцами по ключу.

### Put

```erlang
{ok, C0} = thrift_client_util:new("localhost", 9090, hbase_thrift, [{connect_timeout, 5000}]),
Mutations = [#'Mutation'{column= "data:age", value= <<"17">>}]
{C1, {ok, _}} = thrift_client:call(C0, mutateRow, ["users", "mike", Mutations, dict:new()]),
thrift_client:close(C1).
```

Новое значение для столбца в записи #'Mutation' может быть либо строкой, либо
binary (<<"17">>).

### Scan

```erlang
{ok, C0} = thrift_client_util:new("localhost", 9090, hbase_thrift, [{connect_timeout, 5000}]),
Scan = #'TScan'{'columns'=["data:sex"]},
{C1, {ok, ScannerId}} = thrift_client:call(C0, scannerOpenWithScan, ["users", Scan, dict:new()]),
{C2, {ok, Results}} = thrift_client:call(C1, scannerGetList, [ScannerId, 10]),
=> [#'TRowResult'{row = <<"caleb">>,
               columns = {dict,1,16,16,8,80,48,
                               {[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]},
                               \{\{[],[],
                                 [[<<"data:sex">>|
                                   #'TCell'{value = <<"male">>,timestamp = 1432372800621}]],
                                 [],[],[],[],[],[],[],[],[],[],[],[],...\}\}},
               sortedColumns = undefined},
    #'TRowResult'{row = <<"mike">>,
               columns = {dict,1,16,16,8,80,48,
                               {[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]},
                               \{\{[],[],
                                 [[<<"data:sex">>|
                                   #'TCell'{value = <<"male">>,timestamp = 1432370741107}]],
                                 [],[],[],[],[],[],[],[],[],[],[],...\}\}},
               sortedColumns = undefined}]
{C3, {ok, _}} = thrift_client:call(C2, scannerClose, [ScannerId]),
thrift_client:close(C3).
```

У #'Scan' можно задать не только столбцы, но и другие параметры: стартовую
строку, конечную строку, фильтр (рассмотрен ниже).

### Scan с фильтром и начальной строкой

```erlang
{ok, C0} = thrift_client_util:new("localhost", 9090, hbase_thrift, [{connect_timeout, 5000}]),
FilterString = "(SingleColumnValueFilter('data', 'sex', =, 'binary:male', true, true))",
Scan = #'TScan'{'filterString'=FilterString,'startRow'="caleb1",'columns'=["data:sex"]},
{C1, {ok, ScannerId}} = thrift_client:call(C0, scannerOpenWithScan, ["users", Scan, dict:new()]),
{C2, {ok, Results}} = thrift_client:call(C1, scannerGetList, [ScannerId, 10]),
=> [#'TRowResult'{row = <<"mike">>,
               columns = {dict,1,16,16,8,80,48,
                               {[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]},
                               \{\{[],[],
                                 [[<<"data:sex">>|
                                   #'TCell'{value = <<"male">>,timestamp = 1432370741107}]],
                                 [],[],[],[],[],[],[],[],[],[],[],[],...\}\}},
               sortedColumns = undefined}]
{C3, {ok, _}} = thrift_client:call(C2, scannerClose, [ScannerId]),
thrift_client:close(C3).
```

Здесь мы фильтруем всех пользователей по атрибуту sex. Последние 2 параметра
сообщают HBase, что надо исключить из результирующей выборки строки, где данный
атрибут отсутствует и забрать только последнюю версию (по умолчанию HBase
хранит 5 версий). [Документация по
SingleColumnValueFilter](https://hbase.apache.org/apidocs/org/apache/hadoop/hbase/filter/SingleColumnValueFilter.html).

Обратите также внимание на значение startRow - `caleb1`. Постфикс (1 байт в
конце) нужен для того, чтобы не включать данную строку в результат.

### Delete

```erlang
{ok, C0} = thrift_client_util:new("localhost", 9090, hbase_thrift, [{connect_timeout, 5000}]),
{C1, {ok, _}} = thrift_client:call(C0, deleteAll, ["users", "caleb", "data:age", dict:new()]),
thrift_client:close(C1).
```

удалит столбец age (все версии) у пользователя caleb.

Заключение
==========

С Thrift'ом работать можно, если приноровиться. Конечно, проблемы еще есть
(https://issues.apache.org/jira/browse/THRIFT-2842https://issues.apache.org/jira/browse/THRIFT-2842),
но они решаются.

Полезные ссылки:

- http://wiki.apache.org/hadoop/Hbase/ThriftApi
- http://rambocoder.com/?p=142
- http://kungfooguru.wordpress.com/2009/08/31/erlang-thrift-and-hbase/

[1]: http://en.wikipedia.org/wiki/Apache_Avro
[2]: http://hbase.apache.org/book.html#c
[3]: http://stackoverflow.com/a/13755031/820520
[4]: https://wiki.apache.org/hadoop/Hbase/Stargate
