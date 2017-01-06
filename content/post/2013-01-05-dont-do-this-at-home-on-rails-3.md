---
categories:
- ruby
- ruby-on-rails
- security
- yaml
comments: true
date: 2013-01-05T00:00:00Z
title: 'Don''t do this at home on Rails #3'
slug: dont-do-this-at-home-on-rails-3
---

- Languages: Ruby
- Difficulty: <span class="label label-success">Easy</span>

A lot of time has passed since my last post, so I decided to fix this
little drawback. Next, we will discuss three small pieces of code,
which smells not very good. Let's see what we can do about it.

<!--more-->

### \#1 - Vulnerabilities in code

Let's take a closer look at two methods from the controller:

{% codeblock lang:ruby %}
def show_with_fragments
  constant = get_constant_from_param
  if constant
    obj = constant.find(params[:id])
    data = obj.attributes
    data.merge!(:telecasts => obj.telecasts.map(&:as_json)) if obj.is_a?(TvShow::Programme)
    data.merge!(:seasons => obj.seasons.map(&:as_json)) if obj.is_a?(TvShow::Serial)
    render :json => data
  else
    render :json => {}
  end
end

private

def get_constant_from_param(type = nil)
  param = type || params[:type]
  begin
    constant = param.constantize
    constant if constant < ActiveRecord::Base
  rescue NameError
    nil
  end
end
{% endcodeblock %}

So, what happens here?

1. We receive the type of the model (`params[:type]`) and convert string
to a constant using [constantize](http://apidock.com/rails/v3.2.8/ActiveSupport/Inflector/constantize);
2. We find the record with a given id (`params[:id]`) and select all its
attributes and attributes of the associated objects.

We expect that the `type` will be either "TvShow::Programme" or "TvShow::Serial".
But what if `type` will be "User". We will get access to all the attributes of the
`User` model. This is a serious security issue in our application.

The first step is to limit `type` to the `TvShow` class descendants only.

{% codeblock lang:ruby %}
def show_with_fragments
  constant = get_constant_from_param
  unless constant.is_a?(TvShow)
    raise ArgumentError, “type should be TvShow class descendant”
  end
  if constant
    obj = constant.find(params[:id])
    data = obj.attributes
    data.merge!(:telecasts => obj.telecasts.map(&:as_json)) if obj.is_a?(TvShow::Programme)
    data.merge!(:seasons => obj.seasons.map(&:as_json)) if obj.is_a?(TvShow::Serial)
    render :json => data
  else
    render :json => {}
  end
end
{% endcodeblock %}

The code above violates [OCP](http://en.wikipedia.org/wiki/Open/closed_principle)
principe. Because we want to take advantage of polymorphism,
lets move the logic of getting the attributes of associated
objects into the classes themselves (see `complete_attributes_json` method).
This will allow us to remove all those ugly is_a? checks.

{% codeblock lang:ruby %}
def show_with_fragments
  constant = get_constant_from_param
  unless constant.is_a?(TvShow)
    raise ArgumentError, “type param should be TvShow accessor class”
  end
  if constant
    obj = constant.find(params[:id])
    render :json => obj.complete_attributes_json
  else
    render :json => {}
  end
end
{% endcodeblock %}

Looks better, right?

### \#2 - Take advantage of YAML language

Despite the fact that most of rails applications (and others) using
[YAML](http://en.wikipedia.org/wiki/YAML) to store the translations and settings,
not many of us knows all its features. Two features that
distinguish YAML from the capabilities of other data serialization languages
​​are Relational trees and Data Typing. The most interesting is the first one.
It allows us to attach the anchors (&) on the elements and refer to them
using references (\*). To understand this, it is useful to imagine
a document as a tree.

For example, here is some common locale file `config/locales/en.yml`:

{% codeblock lang:yaml %}
en:
  helpers:
    submit:
      product:
        create: 'Create it'
        update: 'Save it'
      product_item:
        create: 'Create it'
        update: 'Save it'
{% endcodeblock %}

What if we could define the translations for helpers `create` and `update`
in one place, and then use them in other cases. Usually these translations
rarely changes, so, in this case, this is just what we need.

{% codeblock lang:yaml %}
en:
  helpers:
    submit:
      product:
        create: &create 'Create it'
        update: &update 'Save it'
      product_item:
        create: *create
        update: *update
{% endcodeblock %}

Here we have created two anchors and referred to them inside product_item
through two links. Advantages: avoiding possible errors (define
in one place) and compactness. Also, in future, if the translation will needs
to be changed, we wont spend much time to perform the appropriate changes.

You can anchor not only tree nodes, but also the whole branches:

{% codeblock lang:yaml %}
common: &COMMON
  adapter: postgresql
  encoding: unicode
  pool: 10

development:
  <<: *COMMON
  database: db_name
  username: postgres
  password:
{% endcodeblock %}

### \#3 - Look for existing method before writing your own

Maybe I'm repeating myself, but this is exactly the case where repetition
will only benefit.

Before you write any functionality, that is not relevant to the
application's business logic, it is always better to look, maybe someone
has already implemented it. And very often it is. All we are know the
advantages of using existing solutions (libraries). And I think, if you like
it (you can not see any obstacles - performance, memory, that can stop you),
it is better to use it.

{% codeblock lang:ruby %}
def keys_to_symbols(data)
  res = {}
  data.each do |k, v|
    res[k.to_sym] = v.is_a?(Hash) ? keys_to_symbols(v) : v
  end
  res
end
{% endcodeblock %}

I found this method in one controller. It takes the hash and symbolize all
the keys. This functionality already implemented in the `active_support` gem,
which is also enabled by default in rails. The method we are looking for -
[symbolize_keys](http://apidock.com/rails/Hash/symbolize_keys)
