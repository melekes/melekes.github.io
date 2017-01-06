---
categories:
- java
- http-client
- testing
comments: true
date: 2015-02-15T12:04:01Z
title: Тестируем HTTP клиент на Java
slug: testing-http-client-in-java
---

Не так давно, для одного из проектов, пришлось написать простенький HTTP клиент
на Java. Он совсем простой и состоит буквально из одного метода -
[Gist](https://gist.github.com/akalyaev/63b9084d3804f72be2d7#file-httpclient-java).
Поэтому я решил не использовать Apache's HTTPClient и другие библиотеки, вроде
Unirest или Google HTTP Client. Хотя, если бы требовалось что-то посерьезнее,
нежели простые HTTP запросы, рассмотрел бы другие варианты.

<!--more-->

Для тестирования нам понадобятся следующие библиотеки:

* JUnit
* [Mockito](https://github.com/mockito/mockito)
* [PowerMock](https://code.google.com/p/powermock/)

{% gist 63b9084d3804f72be2d7 HttpClientTest.java %}

На мой взгляд, код получился очень понятным и не требует детального пояснения.

Единственное, стоит пожалуй разъяснить зачем нужны аннотации сверху класса.
Первая из них - `@RunWith`, заменяет стандартный JUnit runner тестов на
PowerMock'овский. Вторая аннотация - `@PrepareForTest`, подготавливает классы для
тестов, так как они (классы) будут возвращать mock-объект (URL) или являются
final (HttpClient). [Документация по @PrepareForTest](https://powermock.googlecode.com/svn/docs/powermock-1.3.5/apidocs/org/powermock/core/classloader/annotations/PrepareForTest.html)

Пример JSON'а, возвращаемого в случае успешного ответа:

{% gist 63b9084d3804f72be2d7 search.json %}

Файл `search.json` необходимо поместить по следующему пути:
`src/test/resources/http_client/search.json`. Иначе, если вы напутаете с
путями, `getResourceAsStream` вернет `null`.

Если вы знаете best practices по написанию тестов на Java, или используете
другую библиотеку, которая позволяет убрать часть mock'ов из кода теста, я буду
рад если вы оставите комментарий.
