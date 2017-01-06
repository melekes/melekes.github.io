---
categories:
- ruby
- ruby-on-rails
- activerecord
- migrations
- db
- schema
comments: true
date: 2012-11-18T00:00:00Z
title: Null migration, or What to do when there are too many migrations
slug: null-migration-or-what-to-do-when-there-are-too-many-migrations
---

Migrations are probably one of the most killer features of ActiveRecord.
They allow you to design the architecture of the database along with the
growth of your project. If you change your data model ([Domain Model](http://martinfowler.com/eaaCatalog/domainModel.html)),
you reflect that change in code and write a migration (or several migrations),
which will make the necessary actions on your database schema. This may be
creating a new table, deleting a column or adding an unique index.

<!--more-->

**UPD (2015-02-15)**: recently I have discovered a gem called
[squasher](https://github.com/jalkoby/squasher), which, I presume, does exactly
what this article describes, so check it before continuing reading.

There are many benefits of using migrations, which you should definitely know
about. For example, independency from a particular database or the ability to
easily switch between different states of the database using the rake commands
`db:migrate` and `db:rollback`. More detailed information about them you could
find in the [RailsGuides Migrations](http://guides.rubyonrails.org/migrations.html) article.

## The problem

Sooner or later, especially in the long-running projects, **the number of
migrations exceeds any acceptable norms**. When they are 50, it is perfectly
acceptable. But in really big projects, their number can be up to 500 or even more.

## What can we do?

Create a **null migration** (or initial migration) - migration, which contains
all previous migrations, i.e. the current state of the database schema
(`db/schema.rb` or `db/sctructure.sql`, depending on the format). Thus,
we get **one migration instead of several hundred**.

Pros:

- only one migration
- increased the speed and, consequently, reduced the time for running migrations

Cons:

- large size of the null migration
- all migrations merged into one, so we cannot switch between them any more

Let me remind you that the format of the database schema is defined in
`config/application.rb` file using `config.active_record.schema_format` parameter.
Possible values ​​are `:ruby` ​​or `:sql`. The default is `:ruby`. The main difference
between them is that the second one goes with support for the functions specific
to a particular database (e.g., PostgreSQL sequences).

Next, I will show how you can create a null migration.

## Creating a null migration (schema format - `:ruby`)

1. Dump your schema
2. Create a migration
3. Change migration timestamp
4. Remove previous migrations

### 1. Dump your schema

In most cases, you should already have a file `db/schema.rb`. If not, use the following rake task:

{% codeblock lang:bash %}
> rake db:schema:dump
{% endcodeblock %}

It should do the job.

### 2. Create a migration

Create a new migration named `NullMigration` using Rails generator:

{% codeblock lang:bash %}
> rails g migration NullMigration
{% endcodeblock %}

Open the newly created migration. It should look something like this:

{% codeblock lang:ruby %}
class NullMigration < ActiveRecord::Migration
  def up
  end

  def down
  end
end
{% endcodeblock %}

Now copy the contents of the `ActiveRecord::Schema.define` block from a file `db/schema.rb` into the method `up`.

It remains to take care of the method `down`, which is responsible for
rolling back our migration. Sure, we can go through all migrations and
copy the content of all `down` methods, but it is too expensive. Instead,
let's make our first migration irreversible, especially, there is no much
sense in rolling back to an empty database (we can always delete and create the required
database using the rake command `db:drop db:create`).

As a result, the migration should look like this:

{% codeblock lang:ruby %}
class NullMigration < ActiveRecord::Migration
  def up
    create_table "table", :force => true do |t|
    ...
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
{% endcodeblock %}

### 3. Change migration timestamp

Now, if you'd try to run a migration, you will get an error, because we already
have all the structures (tables, indexes) in our database. ActiveRecord checks
migration state (whether it was executed or not) by looking into
`schema_migrations` table. This table basically holds the timestamps of
all executed migrations.

So, if we do not want ActiveRecord to run our null migration, we either
need to manually insert its timestamp or change it (timestamp) to the last
executed migration timestamp, which is much easier to do.

Let's do this.

1. Find the file with the last executed migration (migration before the null migration) and copy its timestamp
2. Replace the null migration timestamp with it.

Alternatively, you can find the required timestamp inside the
`ActiveRecord::Schema.define(:version => 20120925084251)` block (or at the end of
`null_schema.sql` in case of `:sql` schema format)

Example (using the command line):

{% codeblock lang:bash %}
> ls db/migrate

20120925084251_add_state_to_task_topics.rb
20121120080714_null_migration.rb

> mv 20121120080714_null_migration.rb 20120925084251_null_migration.rb
> ls db/migrate

20120925084251_add_state_to_task_topics.rb
20120925084251_null_migration.rb
{% endcodeblock %}

### 4. Remove previous migrations

Now you only have to remove the previous migrations. I think this you can do without my help :)

## Creating a null migration (schema format - `:sql`)

1. Dump your schema
2. Create a migration
3. Change migration timestamp
4. Remove previous migrations

### 1. Dump your schema

This step is not much different from the above, with the exception of the
schema file - `db/structure.sql` and rake command to dump the database:

{% codeblock lang:bash %}
> rake db:structure:dump
{% endcodeblock %}

Would like to note that, unlike the command `rake db:schema:dump`, which uses
built-in ActiveRecord schema dumper, this command uses special tools
specific to a particular database (for example, pg_dump for PostgreSQL).

### 2. Create a migration

Create a migration (see a similar step above). Next, copy the file
`db/structure.sql` into folder `db/migrate` and rename it to `null_schema.sql`.

Our migration would look like this:

{% codeblock lang:ruby %}
class NullMigration < ActiveRecord::Migration
  def up
    file_data = File.read('db/migrate/null_schema.sql')
    ActiveRecord::Base.connection.execute file_data
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
{% endcodeblock %}

### 3. Change migration timestamp
### 4. Remove previous migrations

## Wrapping Up

Creating a null migration - a convenient way to get rid of a large number
of migrations. Therefore, we become able to restart the database development
cycle, i.e. to start from scratch.

I believe that null migration was invented a long time ago, but I could
not find anything on the internet on this subject, so decided to share with
you. If you have any questions or additions, be sure to leave them
in the comments to this article.

*Thank you to Alexey Astafyev, Alexander Rozhnov and Igor Kuznetsov for reviewing this post.*
