---
tags:
- tutorials
- ruby
- ruby-on-rails
- refactoring
comments: true
date: 2012-11-10T00:00:00Z
title: 'Don''t do this at home on Rails #2'
slug: dont-do-this-at-home-on-rails-2
---

- Languages: Ruby
- Difficulty: <span class="label label-success">Easy</span>

## Intro

Now is the time to break down the next three examples of code that look
slightly chapped, and just beg to be retouched. Despite the apparent
complexity, by running a series of easy refactorings, we can significantly
improve the code: reduce the size, improve the readability and even
increase its speed. Who knows?

<!--more-->

Well, let's start.

### \#1 - prefer Time.current over Time.zone.now or Time.zone

Very often I see a code like this:

{% codeblock lang:ruby %}
if schedulled_at > Time.zone.now
  ...
end
{% endcodeblock %}

And there is nothing wrong with it :) Seriously. But what if we have not set
the time zone? Most likely we'll get an error. Just recently I came across a
method that does this check for us.

[Time.current](http://apidock.com/rails/Time/current/class) - returns
`Time.zone.now` if the `Time.zone` or `config.time_zone` set,
otherwise just returns `Time.now`.

{% codeblock lang:ruby %}
if schedulled_at > Time.current
  ...
end
{% endcodeblock %}

### \#2 - Avoid using `before_filter`

`before_filter` is used inside controllers to execute any code before any action
will be executed. This allows us to avoid duplicating code. But, like any tool,
it can be used "in the wrong way".

{% codeblock lang:ruby %}
class SubscribesController < ApplicationController
  before_filter :load_subscribe, only: [:show, :destroy]

  def index
    @subscribes = Subscribe.all
  end

  def show
  end

  def destroy
    @subscribe.destroy
    redirect_to :root
  end

  private

    def load_subscribe
      @subscribe = Subscribe.find_by_name(params[:id]) || raise(ActiveRecord::RecordNotFound)
    end
end
{% endcodeblock %}

I do not mind eliminating duplication, especially when the private method below
does consist of 40 lines, for example. I just think, logic should be more explicit
here. Otherwise, to understand what makes a particular action, the programmer
must first look at all before filters, then look at the methods that are
called by these filters and only then he or she comes to the action itself. This makes
the application logic confusing and difficult to understand.

Before filters are really helpful in some cases. For example, when we need to check
whether the user is authorized or log each request.

{% codeblock lang:ruby %}
class SubscribesController < ApplicationController
  def index
    @subscribes = Subscribe.all
  end

  def show
    load_subscribe
  end

  def destroy
    load_subscribe
    @subscribe.destroy
    redirect_to :root
  end

  private

  def load_subscribe
    @subscribe = Subscribe.find_by_name!(params[:id])
  end
end
{% endcodeblock %}

When you look at each action it doesn't seem like the instance variables appear
magically. As the capabilities of a controller increases in size it becomes more
difficult to see the "magic" of a before filter hidden somewhere in the app
and the explicitness of method calling becomes very helpful.

Note that I added `!` sign to the `find_by_name` method, which now throws an exception if the
corresponding record is not found. Next, I would probably get rid of the private
method, since it consists only of one line.

### \#3 - Use powerful `Enumerable` methods (example with `select`)

Module [Enumerable](http://ruby-doc.org/core-1.9.3/Enumerable.html) provides a
variety of methods for manipulating, traversing and searching though a
collection. It is very hard to remember them all, but that is not necessary.
What is required of us, is to simplify code by maximum.

Now I will show you two main sources that help me every day:
- [APIdock](http://apidock.com/)
- [Ruby 1.9.3 Doc](http://ruby-doc.org/core-1.9.3/)

{% codeblock lang:ruby %}
# before
@groups = Group.all.find_all { |g| g.admin?(current_user) }
@projects = Project.all.find_all { |p| p.admin?(current_user) }

# after
@groups = Group.select { |g| g.admin?(current_user) }
@projects = Project.select { |p| p.admin?(current_user) }
{% endcodeblock %}

As you can see, the code has not changed much.
But, using such a bricks, we can build really powerful self-documenting code.

After all, this leads to a reducing of complexity, which makes the code
transparent and flexible. As a result, we can do refactor
it without any problems.

And that's all for today folks!

## Following reading
- [Don't do this at home on Rails #3](/2013/01/dont-do-this-at-home-on-rails-3)
