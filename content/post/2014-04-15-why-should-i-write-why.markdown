---
categories:
- git-commit
- git
- coding-style
comments: true
date: 2014-04-15T14:58:08Z
title: Почему стоит писать почему
slug: why-should-i-write-why
---

Раньше в сообщении к коммиту я ограничивался только ответом на вопрос
"Что?".

```
commit 210a1f2df795bf49bfdd08e50d22ba80bac141f1
Author: Anton Kalyaev <anton.kalyaev@gmail.com>
Date:   Mon Apr 14 13:20:06 2014 +0400

    raise NoSlidesError if no slides
```

<!--more-->

Что сделали, то и пишем:

* добавили - added
* удалили - removed
* отрефакторили - refactored
* ... ну вы поняли.

Это позволяет быстро понять что было сделано в рамках данного коммита.

Со временем я осознал, что у данного подхода есть один серьезный
минус - он не отвечает на вопрос "Почему это было сделано?". Позже я
убедился, что в некоторых ситуациях __это способно сильно осложнить
жизнь простому разработчику__.

Рассмотрим случай выше. Непонятно почему мы бросаем исключение, а не
логгируем ошибку. Мы уже не можем быстро поменять данную
функциональность. Приходится самому додумывать причину. Словом __при
отсутствии причины внесения изменений увеличивается стоимость поддержки
данного кода__.

```
commit 210a1f2df795bf49bfdd08e50d22ba80bac141f1
Author: Anton Kalyaev <anton.kalyaev@gmail.com>
Date:   Mon Apr 14 13:20:06 2014 +0400

    raise NoSlidesError if no slides

    This is exceptional situation because if there are no slides, layout
    looses it's meaning.
```

Теперь становится ясно, что в случае отсутствия слайдов лейаут теряет свой
смысл. Мы ожидаем, что будет присутствовать хотя бы один слайд.

_Прошу вас, не вдавайтесь в терминологию предметной области. Для интересующихся
лишь отмечу, что исключение обрабатывается уровнем выше._

Еще пара советов:

* не используйте `git commit -m ""`. Она(команда) принуждает вас писать короткие
сообщения (например, "fixed nil error")
* по возможности ссылайтесь на внешние источники информации (номер тикета,
ссылка на баг в Airbrake, ссылка на статью в интернете и т.п.)
* первая строка не должна быть длиннее 72 символов. Следующее после нее
расширенное описание может быть любой длинны. В качестве разделителя идет пустая
строка.
* если вы пользуетесь Vim, то можно добавить проверку правописания и ограничение
длины текста добавив это в ваш `~/.vimrc`:

  ```
  autocmd Filetype gitcommit setlocal spell textwidth=72
  ```

Полезные ссылки:

* [Every line of code is always documented](http://mislav.uniqpath.com/2014/02/hidden-documentation/)
* [5 Useful Tips For A Better Commit Message](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message)

_Отдельное спасибо [@plugin73](https://twitter.com/plugin73) и [@SavelyevAndrey](https://twitter.com/SavelyevAndrey) за ревью_.
