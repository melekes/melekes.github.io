---
categories:
- erlang
comments: true
date: 2016-04-25T10:38:13Z
title: Как стартовать Erlang приложение
slug: how-do-i-start-erlang-application
---

Подразумевается, что у вас уже есть какое-то приложение и вы используете 3й
rebar.

<!--more-->

_Disclaimer: этот способ, который принят у меня в компании и которого
придерживаюсь я. Он не претендует на звание "единственно правильный способ".
Если вы видите явные недочеты, пишите в комментариях._

Как запускаем приложение при разработке
=======================================

```makefile
# Makefile

.PHONY: all compile run

REBAR=./rebar3

all: compile

compile:
    $(REBAR) compile

run: compile
		erl -pa _build/default/lib/*/ebin -config config/sys.config -args_file config/vm.args -boot start_sasl -s sync -s yourawesomeapp
```

sasl нужен для более красивых и подробных сообщениях об ошибках и не только:
запуск, перезапуск, падение частей приложения.

https://github.com/rustyio/sync перекомпилирует и перезагружает код налету.

`-s yourawesomeapp` попытается вызвать `yourawesomeapp:start()`, так что нужен файл следующего содержания (если у вас его еще нет):

```erlang
-module(yourawesomeapp).

-export([start/0]).

-spec start() -> 'ok'.
start() ->
    {ok, _} = application:ensure_all_started(yourawesomeapp),
    ok.
```

ensure_all_started удостоверится, что все зависимости вашего приложения запущены.

Плохой практикой считается старт зависимостей вручную:

```
% ПЛОХО
% yourawesomeapp_app.erl

-spec start(any(), any()) -> no_return().
start(_StartType, _StartArgs) ->
    lager:start(),
    yourawesomeapp_sup:start_link().

% ХОРОШО
% yourawesomeapp.app.src

{application, yourawesomeapp,
 [
  {description, "Dope app #1"},
  ...
  {applications, [
                  kernel,
                  stdlib,

                  lager
                 ]},
  ...
 ]}.
```

```erlang
% config/sys.config

[
    {yourawesomeapp, [
    ]},

    %% SASL config
    {sasl, [
        {sasl_error_logger, {file, "log/sasl-error.log"}},
        {errlog_type, error},
        {error_logger_mf_dir, "log/sasl"},
        {error_logger_mf_maxbytes, 10485760},
        {error_logger_mf_maxfiles, 5}
    ]}
].
```

```erlang
% config/vm.args

## Name of the node
-sname yourawesomeapp

## Cookie for distributed erlang
-setcookie XXX

## Heartbeat management; auto-restarts VM if it dies or becomes unresponsive
## (Disabled by default..use with caution!)
##-heart

## Enable kernel poll and a few async threads
+K true
+A 10

## Distribution buffer busy limit (dist_buf_busy_limit)
+zdbbl 8192

## Sets mapping for warning messages
+W w

## Sets  the number of scheduler threads to create and scheduler
## threads to set online when SMP support has been enabled.
#+S 2:2

## Increase number of concurrent ports/sockets
##-env ERL_MAX_PORTS 4096

## Tweak GC to run more often
##-env ERL_FULLSWEEP_AFTER 10

## Application libraries
##-env ERL_LIBS /srv/projects/yourawesomeapp

## Increase the maximum number of simultaneously existing processes
+P 1048576
```

Как запускаем приложение в продакшене
=====================================

Тут все зависит от того, релизы у вас или нет. Если релизы, при сборке вы просто указываете нужные vm.args и sys.config:

```
{relx, [
    {release, {yourawesomeapp, "1.0.0"},
     %% list of apps to include
     [yourawesomeapp, sasl, lager]},

    %% Don't ship an Erlang VM by default
    {include_erts, false},

    {vm_args, "./config/vm.args"}
]}.

{profiles, [
    %% called as `rebar3 as prod <command>`
    {prod, [
        {relx, [ % override relx specifically
          {include_src, false}, % don't include source code
          {include_erts, true},  % include the VM in the release

          {sys_config, "./config/production.config"}
        ]}
    ]}
]}.
```

Если нет, можно указать vm.args и sys.config посредством ключей к `erl` (см.
make run) или использовать переменные окружения: ARGS_FILE и CONFIG_FILE.

Полезные ссылки:

- [Короткий туториал от настройки среды до создания релиза](https://howistart.org/posts/erlang/1)
- [Описание разных способов создать релиз](https://github.com/juise/myapp)
