---
categories:
- ruby
- docker
comments: true
date: 2015-05-07T11:53:25Z
title: Разрабатываем ruby gem в docker контейнере
slug: razrabatyvaiem-ruby-gem-v-docker-kontieinierie
---

<img class="img-rounded" src="/images/posts/2015-05-07-razrabatyvaiem-ruby-gem-v-docker-kontieinierie/logo.png" alt=""/ width="450" title="Разрабатываем ruby gem в docker контейнере">

Контейнеры захватывают вселенную, и ничего с этим не поделаешь. Несмотря на то,
что я являюсь старым приверженцем Vagrant'а, на днях мне все же захотелось
попробовать docker для одного из своих проектов -
[Valle](https://github.com/kaize/valle). Не без препонов, но все же удалось
встроить docker в процесс. Далее последует руководство по разработке Ruby гема
с использованием docker'а.

<!--more-->

*Небольшое отступление*: я не знаю кто победит в битве тулов - docker или
rocket и КО, которые недавно выпустили общую спецификацию на контейнеры - [App
Container](https://github.com/appc/spec), или еще кто-то. Пусть победит
сильнейший. docker я выбрал по 2 причинам: 1) он уже давно стабилен и вполне
годен для повседневного использования (для разработки точно) 2) это довольно
большая платформа с кучей готовых рецептов и туториалов.

### 1. Устанавливаем docker

Все команды актуальны для Ubuntu. Инструкции для других ОС читайте на
официальных сайтах.

И так, начнем. Первым делом нам надо установить сам docker (для других ОС см.
[инструкцию](http://docs.docker.com/installation/)):

```sh
$ wget -qO- https://get.docker.com/ | sh
```

Чтобы каждый раз не писать sudo при его использовании, создадим группу docker и
добавим своего пользователя в нее:

```sh
$ sudo usermod -aG docker <username>
```

### 2. Создаем Dockerfile

Следующим нашим шагом будет создание Dockerfile'а для нашего гема. Создайте
Dockerfile со следующим содержимым в корне вашего гема:

```dockerfile
# Dockerfile
FROM ruby:2.2.2

RUN mkdir -p /usr/src/lib
WORKDIR /usr/src/lib

COPY Gemfile* /usr/src/lib/
COPY *.gemspec /usr/src/lib/
RUN bundle install

COPY . /usr/src/lib/
```

Вы можете натолкнуться на ошибку мол "Не могу найти lib/<yourgemname\>/version.rb" если
загружаете его (файл с версией) в gemspec файле. Решением будет добавить еще
одну инструкцию COPY перед bundle install или [удалить
его к чертям](https://github.com/kaize/valle/commit/cfb4e8e451c54bb94176577811de72a01740d501#diff-6e266e394c50981ec99b03694aa7ccc0L2).

```dockerfile
RUN mkdir -p /usr/src/lib/<yourgemname>
COPY lib/<yourgemname>/version.rb /usr/src/lib/<yourgemname>/version.rb
```

Если вы только начинаете разрабатывать гем и вам нужно создать его скелет выполните:

```sh
$ docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/lib -w /usr/src/lib ruby:2.2.2 bundle gem <yourgemname>
```

Эта команда создаст поддиректорию <yourgemname\> внутри текущей.

По умолчанию COPY скопирует все файлы и папки внутрь контейнера. Хорошей
практикой считается добавление .dockerignore в проект (как .gitignore,
только для docker'а):

```
# .dockerignore
pkg/
```

Также можно заморозить bundler, чтобы он выкидывал ошибку каждый раз, когда вы
пытаетесь запустить что-то при измененном Gemfile. То есть, вам придется
выполнить `bundle install` и пересобрать контейнер (опционально).

```dockerfile
# Dockerfile
FROM ruby:2.2.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

...
```

`bundle install` выполняем так:

```sh
$ docker run --rm -v "$PWD":/usr/src/lib -w /usr/src/lib ruby:2.2.2 bundle install
```

Другие хорошие практики можно прочесть здесь - [Best practices for writing
Dockerfiles](https://docs.docker.com/articles/dockerfile_best-practices/)

### 3. Собираем контейнер и запускаем тесты

Результирующий Dockerfile должен выглядеть примерно так:

```dockerfile
# Dockerfile
FROM ruby:2.2.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/lib
WORKDIR /usr/src/lib

COPY Gemfile* /usr/src/lib/
COPY *.gemspec /usr/src/lib/
RUN bundle install

COPY . /usr/src/lib/
```

Теперь соберем наш контейнер:

```sh
$ docker build -t <yourgemname> .
```

И запустим тесты:

```sh
$ docker run -it --rm -v "$PWD":/usr/src/lib <yourgemname> bundle exec rake
```

Все должно отработать без проблем.

### 4. Makefile (опционально)

Хорошей идеей также будет добавить Makefile:

```makefile
docker_build:
	docker build -t <yourgemname> .

docker_test:
	docker run -it --rm -v "$(PWD)":/usr/src/lib <yourgemname> bundle exec rake

.PHONY: docker_build docker_test
```

или использовать [docker-compose](https://docs.docker.com/compose/).

### 5. Результаты

Все это работает очень шустро (по крайней мере на моем Linux'е). Поговаривают,
что на маках ситуация чуть хуже по понятным причинам.

Таким образом, все что потребуется от нашего коллеги или контрибьютора для
старта работы над гемом - это выполнить пару команд! Я считаю это здорово. Нет,
вы конечно можете добавить Vagrantfile вместе  с provisioning, но виртуалки
тяжелые и съедают много ресурсов. Или сказать, что для работы над гемом вам
нужно поставить Ruby, libXX1 и libXX2 ручками. Но и у этого подхода имеются
серьезные недостатки.

Полезные ссылки:

- https://docs.docker.com/reference/#reference
- https://registry.hub.docker.com/_/ruby/
- https://registry.hub.docker.com/_/rails/
- https://robots.thoughtbot.com/rails-on-docker
