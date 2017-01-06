---
categories:
- erlang
- testing
- meck
comments: true
date: 2015-03-03T11:04:41Z
title: Опции meck:new
slug: meck-new-options
---

Документация по [meck](https://github.com/eproxus/meck)... скажем так, не блещет. Давайте разберем опции `meck:new`.

<!--more-->

* `passthrough` пробрасывает функции meck-модуля (string_meck) в оригинальный модуль (string)

```erlang
meck:new(string, [passthrough]),
meck:expect(string, char_at,
    fun(0) ->
        $a;
    (Pos) ->
        meck:passthrough([Pos])
end),
?assert(meck:validate(string)).
```

* `no_link` не связывать meck процесс с вызывающим процессом. В зависимости от значения используется либо `gen_server:start_link`, либо `gen_server:start`. По умолчанию при падении вызывающего процесса meck выгрузит все модули. **Не понимаю зачем может потребоваться не связывать эти процессы.**

* `unstick` для мокинга stdlib, kernel или compiler. По умолчанию Erlang запрещает перезагружать данные модули в целях безопасности.

* `no_passthrough_cover` запрещает отслеживать покрытие тестами passthrough вызовов. **Видимо когда-то были проблемы при взаимодействии cover и meck и, в результате, родилась данная опция.**

* `{spawn_opt, list()}` позволяет указать `spawn_opt` для `gen_server:start_link`. Подробнее http://erlang.org/doc/man/erlang.html#spawn_opt-4

* `no_history` - не записывать историю.

* `non_strict` позволяет создать expectation для несуществующей функции или даже создать несуществующий модуль. **Не думаю, что эта хорошая практика.**

* `{stub_all, '{@link ret_spec()}'}` замокает все функции модуля и будет возвращать то, что указано вторым параметром.

```erlang
meck:new(string, [stub_all]),
?assertEqual(ok, string:colorize()).

meck:new(string, [{stub_all, true}]),
?assertEqual(true, string:contains($a)).

meck:new(string, [{stub_all, meck:seq([$a, $b, $c])}]),
?assertEqual($a, string:char_at(1)),
?assertEqual($b, string:char_at(2)),
?assertEqual($c, string:char_at(3)),
?assertEqual($c, string:char_at(4)).

meck:new(string, [{stub_all, meck:loop([$a, $b, $c])}]),
?assertEqual($a, string:char_at(1)),
?assertEqual($b, string:char_at(2)),
?assertEqual($c, string:char_at(3)),
?assertEqual($a, string:char_at(4)). %% заметили разницу между seq?
```
