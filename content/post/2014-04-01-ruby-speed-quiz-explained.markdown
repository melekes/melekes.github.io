---
tags:
- quizzes
- ruby
comments: true
date: 2014-04-01T23:47:38Z
title: Ruby speed quiz explained
slug: ruby-speed-quiz-explained
---

At the end of [Ruby speed quiz](/2014/03/ruby-speed-quiz/) I promised to publish an explanation for each case.
I did not expect that more than 900 Rubyists will give it a shot. I
was surprised. Thanks to all who participated!

<!--more-->

But lets go back to the questions.

# 1. Range cover? VS include?

- `('a'..'z').cover?('f')`
- `('a'..'z').include?('f')`
- both run with the similar speed

__cover? is faster__ because it just finds out if the argument is > than the first and < the second.
No looping necessary. include?, in opposite, loops through all elements of the range until it
finds an argument or reaches the end.

```ruby
('a'..'z').cover?('f')
==> 'a' <= 'f' && 'f' <= 'z'

('a'..'z').include?('f')
==> 'a' == 'f'
==> 'b' == 'f'
==> 'c' == 'f'
==> 'd' == 'f'
==> 'e' == 'f'
==> 'f' == 'f'
```

### Caveats

Be careful when using include? and cover?:

```ruby
('a'..'z').include?('blah')
# => false
('a'..'z').cover?('blah')
# => true
'a' < 'blah'
# => true
'blah' < 'z'
# => true
```

See [this post](http://gistflow.com/posts/816-range-include-vs-range-cover) for detailed benchmarks.

# 2. blk.call VS yield

```ruby
def foo
  yield if block_given?
end
foo { puts "Hi from foo" }
```

```ruby
def bar(&blk)
  blk.call
end
bar { puts "Hi from bar" }
```

- both run with the similar speed

__yield is faster__ because the process of procifying a block takes time.

See [this post](http://mudge.name/2011/01/26/passing-blocks-in-ruby-without-block.html) for detailed benchmarks.

# 3. Hash [] VS fetch

```ruby
h = {}
h[:a] || 1
```

```ruby
h = {}
h.fetch(:a, 1)
```

- both run with the similar speed

Using brackets to get goodies out of a hash is the same as fetch because they both use the same code to do exactly the same thing.

```ruby
if (!RHASH(hash)->ntbl || !st_lookup(RHASH(hash)->ntbl, key, &val)) {
```

It checks that the hash is not empty and tries to find the value using a
given key.

# 4. define_method VS class_eval (definition, NOT call speed)

```ruby
class A
  100.times do |i|
    define_method("foo_#{i}") { 10.times.map { "foo".length } }
  end
end
```

```ruby
class B
  100.times do |i|
    class_eval 'def bar_#{i}; 10.times.map { "foo".length }; end'
  end
end
```

- both run with the similar speed

__Define method is faster__ because you don't have to eval the class and then define a method on it. You are already in the class scope. Also on each call to class_eval, MRI creates a new parser and parses the string. In the define_method case, the parser is only run once.

However, it's not that simple. Yes, define_method creates the method faster. But after creation, a short method created with class_eval is usually faster than one created with define_method. That is why you still can find many class_eval instructions
in Rails. These are places where run (not startup) speed matters. So, it's worthwhile to chose based on your use case.

See [this post](http://tenderlovemaking.com/2013/03/03/dynamic_method_definitions.html) for detailed benchmarks.

# 5. super with OR without arguments

```ruby
class Parent
 def bar(a, b)
   puts "#{a} - #{b}"
 end
end

class Child < Parent
 def bar(a, b)
   super
 end
end
c = Child.new
c.bar(1, 2)
```

```ruby
class Parent
  def bar(a, b)
    puts "#{a} - #{b}"
  end
end

class Child < Parent
  def bar(a, b)
    super(a, b)
  end
end
c = Child.new
c.bar(1, 2)
```

- both run with the similar speed

Calling super without arguments passes any arguments along that were passed through to the calling method. So it deals with arguments anyways.
