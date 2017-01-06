---
categories:
- tutorials
- alias
- linux
- history
- shortcuts
- git
- productivity
comments: true
date: 2013-07-28T00:00:00Z
title: 10 команд, которыми вы пользуетесь чаще всего
slug: top-10-commands-you-currently-use
---

Порой, если вы активно пользуетесь командной строкой, вы начинаете
замечать, что набираете некоторые команды по многу раз. Неужели вам не
лень каждый раз набирать `vagrant up` или `git checkout
feature/awesome-feature`? Если да и вы стремитесь к повышению
продуктивности своей работы, то в командной оболочке linux есть отличное средство,
которое нам поможет - алиасы.

<!--more-->

Сначала надо получить список наиболее часто используемых команд:

{% codeblock lang:bash %}
history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
{% endcodeblock %}

`awk` сохраняет команду и количество ее вхождений в
историю. Затем результат печатается, фильтруются скрипты вида
`./something`, сортируется и обрезается до нужной длины.

[Источник](http://linux.byexamples.com/archives/332/what-is-your-10-common-linux-commands/)

Пример вывода:

{% codeblock Output %}
13185  31.8532%   git
21430  14.3014%   gst
3706   7.301406071%   vim
4687   6.87069%   cd
5618   6.18062%   vagrant
6404   4.0404%    sudo
7252   2.52025%   tmux
8232   2.32023%   g
9197   1.9702%    ls
10190  1.90019%   gc
{% endcodeblock %}

Основываясь на выводе выше, можно сказать что я очень часто пользуюсь
git, так что неплохо бы создать алиас для него и команд ниже.

{% codeblock lang:bash %}
alias g="git"
alias v="vim"
alias l="ls -al"
alias c="git commit -m"
{% endcodeblock %}

Мне очень нравятся однобуквенные алиасы. Хотя на многое их явно не
хватит.

Также можно проанализировать только команды vagrant'а (subcommands) или любой
другой программы слегка модифицировав предыдущий скрипт:

{% codeblock lang:bash %}
history|grep vagrant| awk '{CMD[$3]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
{% endcodeblock %}

Пример вывода:

{% codeblock Output %}
1   193  23.9752%   ssh
2   166  20.6211%   up
3   98   12.1739%   halt
4   63   7.82609%   reload
5   37   4.59627%   destroy
6   31   3.85093%   TEAMOCIL=1;
7   18   2.23602%   provision
8   14   1.73913%   box
9   9    1.11801%   solo
10  8    0.993789%  -r
{% endcodeblock %}

Для vagrant мы заведем такой набор:

{% codeblock lang:bash %}
alias v="vagrant"
alias vst="vagrant status"
alias vup="vagrant up"
alias vpr="vagrant provision"
alias vhl="vagrant halt"
alias vre="vagrant reload"
alias vssh="vagrant ssh"
{% endcodeblock %}

Если вы пользуетесь zsh, то рекомендую взглянуть на [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), которая
предлагает большое количесво плагинов с алиасами и автодополнением.
Конечно, они во многом избыточны (стоит хотя бы взглянуть на [список
команд плагина git](http://jasonm23.github.io/oh-my-git-aliases.html)), но если вас это устраивает, то можно смело их
использовать.

**Как результат, мы повышаем продуктивность и, что немаловажно, снижаем нагрузку на наши
пальцы.**

P.S. очень рекомендую посмотреть доклад [Ben Orenstein - Write code faster: expert-level vim (Railsberry 2012)](http://www.youtube.com/watch?v=SkdrYWhh-8s),
в котором Бен рассказывает очень правильные подходы в работе с vim'ом. Даже если вы не
пользуетесь vim'ом, многие вещи можно переложить на ваш любимый редактор, будь то Emacs, Sublime или любой другой.
