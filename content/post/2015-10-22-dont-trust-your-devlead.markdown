---
tags:
- erlang
- profiling
comments: true
date: 2015-10-22T10:16:35Z
title: Не верь своему тимлиду
slug: dont-trust-your-devlead
---

"Не верь своему тимлиду" или когда не стоит слепо верить словам вашего тимлида.

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-10-22-dont-trust-your-devlead/dog.png" alt="" width="100%" title=""/>
</div>

<br/>

<!--more-->

Большинство моих читателей находится в подчинении у тимлида или VP of
Engineering, словом у человека, умудренного опытом или, по крайней мере,
знающего побольше своих подчиненных. И это нормально. И ты доверяешь опыту
данного человека, но бывают случаи, когда стоит все же проверить прав он или
нет.

Так вот, приключился давеча со мной забавный случай. В одном из пулл-реквестов
VP of Engineering мне написал: "Тут можно сильно разогнать, используя в
качестве аккумулятора dict и обновляя значения через dict:update.".

А вот и код, о котором идет речь:

```erlang
% for every Item in Items, коих около 5000
NewAcc = case gb_sets:is_member(RangeStart, RangeStarts) of
  false ->
    case lists:keyfind(norange, 1, Acc) of
      {norange, List} -> [{norange, [Item|List]}|lists:keydelete(norange, 1, Acc)];
      false -> [{norange, [Item]}|Acc]
    end;
  true ->
    case lists:keyfind(RangeStart, 1, Acc) of
      {RangeStart, List} -> [{RangeStart, [Item|List]}|lists:keydelete(RangeStart, 1, Acc)];
      false -> [{RangeStart, [Item]}|Acc]
    end
end,
...
% позже возвращаем результирующий список
NewAcc
```

Обратите внимание, что элементы range хранятся в списках и все операции (за
исключением поиска в сбалансированном дереве) производятся над списками.

Я решил проверить, действительно ли использование dict способно повысить
производительность данного кода (т.е. сократить время выполнения). Для начала
замерил скорость работы со списками:

```
Range: 398 - 7667 mics
Median: 1798 mics
Average: 1846 mics
```

Потом попробовал `dict:append_list`:

```erlang
% for every Item in Items, коих около 5000
NewAcc = case gb_sets:is_member(RangeStart, RangeStarts) of
  false ->
    case dict:is_key(norange, Acc) of
      false -> dict:append(norange, Item, Acc);
      true -> dict:append_list(norange, [Item], Acc)
    end;
  true ->
    case dict:is_key(RangeStart, Acc) of
      false -> dict:append(RangeStart, Item, Acc);
      true -> dict:append_list(RangeStart, [Item], Acc)
    end
end,
...
% позже возвращаем результирующий список
dict:to_list(NewAcc)
```

```
Range: 61466 - 94095 mics
Median: 67062 mics
Average: 68343 mics
```

Он оказался значительно медленнее (из-за того, что списки склеиваются с помощью `++`).

Затем попробовал `dict:update`:

```erlang
% for every Item in Items, коих около 5000
Key = case gb_sets:is_member(RangeStart, RangeStarts) of
  false -> norange;
  true -> RangeStart
end,
NewAcc = dict:update(Key, fun(List) -> [Item|List] end, [Item], Acc),
...
% позже возвращаем результирующий список
dict:to_list(NewAcc)
```

```
Range: 4044 - 11357 mics
Median: 4672 mics
Average: 4963 mics
```

Кода меньше в разы, но по скорости уступает, а на данном участке нам важна была
именно скорость.

<div style="align:center">
  <img class="img-rounded" src="/images/posts/2015-10-22-dont-trust-your-devlead/avgs.png" alt="" width="100%" title=""/>
</div>
(*создал диаграмму с помощью R*)

Конкретные цифры не так важны, ибо они зависят от множества факторов, включая
размер входящего списка Items, количества RangeStart'ов, машинку, на которой
это все запускается, версию Erlang и т.п.

Что важно, так это то, что профессионал своего дела должен уметь распознать
таковые моменты, когда стоит проверить указания или советы вашего тимлида. Я не
думаю, что есть конкретные условия или признаки, которые подскажут вам
необходимость проверки. Скорее знание структур данных используемого вами языка
и механизма работы VM и ОС помогут вам научиться распознавать такие случаи. Так
что читайте книги и помните правило - "доверяй, но проверяй".
