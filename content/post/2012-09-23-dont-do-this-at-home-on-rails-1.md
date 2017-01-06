---
comments: true
date: 2012-09-23T00:00:00Z
tags:
- categories
- ruby
- ruby-on-rails
- refactoring
title: 'Don''t do this at home on Rails #1'
slug: dont-do-this-at-home-on-rails-1
---

- Languages: Ruby
- Difficulty: <span class="label label-success">Easy</span>

## Intro

These series of articles will be dedicated to every day code, that I am working on.
This could be the parts of my own projects or some ruby gems. Together, we will try to improve quality and readability of it.

<!--more-->

## Examples

### \#1 - avoid duplication

The first example is a scope, that fetches the records within a given range.
If the `date` param passed to this block responds to the `first` and `last` methods,
these are considered as start and end dates. Otherwise, it selects records for that date plus 1 day.

{% codeblock lang:ruby %}
scope :at_date, lambda { |date|
  if date.respond_to?(:last) && date.respond_to?(:first)
    where("created_at >= ? AND created_at <= ?", date.first, date.last)
  else
    where("created_at >= ? AND created_at <= ?", date, date + 1.day)
  end
}
{% endcodeblock %}

What could you say about this code? Is it well written? This code has many flaws.
The first thing that caches the eye is duplicated `where` condition.
Just imagine, each time you want to change the query, you will need to update these 2 lines.
Lets fix this.

{% codeblock lang:ruby %}
scope :at_date, lambda { |date|
  if date.respond_to?(:last) && date.respond_to?(:first)
    date_start = date.first
    date_end = date.last
  else
    date_start = date
    date_end = date_start + 1.day
  end

  where("created_at >= ? AND created_at <= ?", date_start, date_end)
}
{% endcodeblock %}

Good, but that's not all.

It seems to me very confusing, that `date` param could be
either `Array` or `DateTime`. Strictly speaking, it could be anything;
e.g `String` - it's also responds to `first/last` methods, so as a result
we will get this query `created_at >= 2 and created_at <= 3` for date = '2012-09-23'.

But wait, ActiveRecord's query interface also supports ranges as an arguments,
so we could write something like this: `where(created_at: date.first..date.last)`,
which will generate a query `created_at BETWEEN <date.first> AND <date.last>`.

{% codeblock lang:ruby %}
scope :at_date, lambda { |range|
  where(created_at: range)
}
{% endcodeblock %}

### \#2 - try to search for existing method first

The second slice of code selects the channels, locked by the current user and
free channels.

{% codeblock lang:ruby %}
cu = current_user
locked = channels.select{ |ch| ch.is_locked_by?(cu) }
free   = channels.select{ |ch| !ch.is_locked_by?(cu) }
{% endcodeblock %}

Did you notice the reverse condition? Every time I see the code,
who looks like this, I thought, it should be already a method for this in ruby.
In fact, ruby and rails has a greater collection of methods. Take a look at `ActiveSupport`
methods <http://apidock.com/rails/ActiveSupport>. But what about our case? After a few minutes
of searching, I've found `partition` method ([Doc](http://apidock.com/ruby/Enumerable/partition)),
which does exactly just we want to - splits collection into two arrays by a given condition.

{% codeblock lang:ruby %}
locked, unlocked = channels.partition { |ch| ch.is_locked_by?(current_user) }
{% endcodeblock %}

### \#3 - think about what you are writing right now

The third method is a simple method inside some model.

{% codeblock lang:ruby %}
def has_description?
  !self.description.blank?
end
{% endcodeblock %}

I know what you are thinking right now - it's not my :)

There are two drawbacks in the code above. The one significant is that there is already a
method for this in `ActiveRecord`. Rails creates a method called `"{attribute}?"`,
which checks whether a field is defined or not. So we could remove `has_description?`
method with `description?`.

Note: you don't have to use `self` inside the model methods, because we already in the context of an object.

And that's all for today. Hope you've caught something for you!

## Following reading
- [Don't do this at home on Rails #2](/2012/11/dont-do-this-at-home-on-rails-2)
