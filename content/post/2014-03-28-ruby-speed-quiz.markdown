---
tags:
- quizzes
- ruby
comments: true
date: 2014-03-28T12:13:48Z
title: Ruby speed quiz
slug: ruby-speed-quiz
---

For each case choose the fastest option.

<!--more-->

_Platform, which hosted this quiz was closed. So it will be read only for some time._

### 1. Range cover? VS include?

1)

```ruby
('a'..'z').include?('f')
```

2)

```ruby
('a'..'z').cover?('f')
```

3) both run with similar speed

### 2. blk.call VS yield

1)

```ruby
def foo
  yield if block_given?
end
foo { puts "Hi from foo" }
```

2) both run with similar speed

3)

```ruby
def bar(&blk)
  blk.call
end
bar { puts "Hi from bar" }
```

### 3. Hash [] VS fetch

1)

```ruby
h = {}
h[:a] || 1
```

2)

```ruby
h = {}
h.fetch(:a, 1)
```

3) both run with similar speed

### 4. super with OR without arguments

1)

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

2) both run with similar speed

3)

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

### 5. define_method VS class_eval (definition, NOT call speed)

1)

```ruby
class A
  100.times do |i|
    define_method("foo_#{i}") { 10.times.map { "foo".length } }
  end
end
```

2)

```ruby
class B
  100.times do |i|
    class_eval 'def bar_#{i}; 10.times.map { "foo".length };
end'
  end
end
```

3) both run with similar speed

Check yourself:

1. 2
2. 1
3. 3
4. 2
5. 1

<hr>

[Here](/2014/04/ruby-speed-quiz-explained/) you could find an explanation for each case.
