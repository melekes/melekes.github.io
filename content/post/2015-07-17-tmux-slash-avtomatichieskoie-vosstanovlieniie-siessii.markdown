---
categories:
- tmux
- shells
- vim
- neovim
comments: true
date: 2015-07-17T10:35:07Z
title: tmux / Автоматическое восстановление сессии
slug: tmux-slash-avtomatichieskoie-vosstanovlieniie-siessii
---

Не так давно собрался с силами, и настроил у себя в tmux автоматическое
сохранение и восстановление последней сессии. По прошествии месяца могу с
уверенностью сказать - просто бомба!

<!--more-->


<img class="img-rounded" src="/images/posts/2015-07-17-tmux-slash-avtomatichieskoie-vosstanovlieniie-siessii/ILKC62E3GC.jpg" alt=""/ width="694" title="tmux / Автоматическое восстановление сессии">


Представьте себе, вы выключили компьютер (не все так поступают, я знаю) и
отправились домой. Вечером, отправив жену готовить борщ, и удобно устроившись
на любимом диване, предварительно включив теплый ламповый свет, вы открываете
свой лэптоп, запускаете shell и вуаля - **все сплиты на том же самом месте, где
они и были в последний раз. Более того, Vim уже запущен и курсор стоит на той
же строке, где он и был в последний раз**.

Для того, чтобы данное чудо заработало и у вас, нам потребуется [Tmux Plugin
Manager](https://github.com/tmux-plugins/tpm) (сокращенно, tpm):

```sh
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

*(примечание: нужен tmux >= 1.9)*

Теперь добавим следующее в конец .tmux.conf:

```
# .tmux.conf

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

run '~/.tmux/plugins/tpm/tpm'
```

Далее остается только загрузить наши изменения и установить плагины:

```sh
$ tmux source ~/.tmux.conf
```

Для установки плагинов нажмите `prefix - I`.

Для комфортной работы стоит добавить пару опций. По умолчанию, tmux-continuum
(плагин, который автоматически сохраняет tmux окружение) не восстанавливает его
при запуске tmux. Что ж, исправим это недоразумение:

```
# .tmux.conf

set -g @continuum-restore 'on'
```

Для того, чтобы при загрузке восстанавливались Vim (Neovim) сессии, нужно

1. установить плагин https://github.com/tpope/vim-obsession
2. добавить пару строк в .tmux.conf:

```
# .tmux.conf

# for vim
set -g @resurrect-strategy-vim 'session'
# for neovim
set -g @resurrect-strategy-nvim 'session'
```

Стоит отметить, что можно стартовать не только Vim, но и любые другие программы
- ssh, psql, rails console, которые были запущены в прошлый раз. Для этого,
  правда, надо добавить их в конфиг:

```
# .tmux.conf

set -g @resurrect-processes 'ssh psql mysql sqlite3'
```

Также у данного плагина (https://github.com/tmux-plugins/tmux-resurrect) есть и
несколько интересных экспериментальный опций, таких как сохранение истории для
каждого сплита и сохранение его содержимого.
