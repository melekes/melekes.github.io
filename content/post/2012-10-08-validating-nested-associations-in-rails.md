---
comments: true
date: 2012-10-08T00:00:00Z
tags:
- tutorials
- ruby
- ruby-on-rails
- activerecord
- forms
- validation
- nested-attributes
- accepts_nested_attributes_for
title: Validating nested associations in Rails
slug: validating-nested-associations-in-rails
---

## Intro

Rails provide a wide range of options for creating rich forms for your models.
This can be a simple form for one object, or the form for many related objects.
Usually it is a parent-children relations. If you are not familiar with such terms
as [form_for](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#M001605)
or [accepts_nested_attributes_for](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#M002132),
I strongly recommend taking a look at this article [Complex Rails Forms with Nested Attributes](http://rubysource.com/complex-rails-forms-with-nested-attributes/),
written by [Xavier Shay](http://xaviershay.com/), which will show your how you can create complex forms with Rails.

<!--more-->

## An example

Suppose, we have a model called `Company`. And the company may have several offices.
Lets define these two models.

{% codeblock lang:ruby %}
class Company < ActiveRecord::Base
  attr_accessible :name, :offices_attributes
  validates :name, presence: true
  has_many :offices
  accepts_nested_attributes_for :offices, allow_destroy: true
end

class Company::Office < ActiveRecord::Base
  attr_accessible :company_id, :name
  validates :name, presence: true
  belongs_to :company
end
{% endcodeblock %}

Both company and office have names. The company could have zero or more offices.

By including `accepts_nested_attributes_for` it becomes possible to access
offices attributes inside our `Company` model.

{% codeblock lang:ruby %}
> c = Company.create(name: 'Mars LLC')
>   => #<Company id: 1, name: "Mars LLC", created_at: "2012-10-08 19:16:44", updated_at: "2012-10-08 19:16:44">

# add two new offices
> c.offices_attributes = [{ name: 'North America' }, { name: 'Europe' }]
>   => [{:name=>"North America"}, {:name=>"Europe"}]
> c.save
> c.offices
>   => [#<Company::Office id: 1, company_id: 1, name: "North America", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:21:54">, #<Company::Office id: 2, company_id: 1, name: "Europe", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:21:54">]

# edit office in North America
> c.offices_attributes = [{ id: 1, name: "North America (it's cold out there)" }]
>   => [{:id=>1, :name=>"North America (it's cold out there)"}]
> c.save
> c.offices
>   => [#<Company::Office id: 1, company_id: 1, name: "North America (it's cold out there)", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:25:18">, #<Company::Office id: 2, company_id: 1, name: "Europe", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:21:54">]

# delete an office in Europe
> c.offices_attributes = [{ id: 2, _destroy: '1' }]
>   => [{:id=>2, :_destroy=>"1"}]
> c.save
> c.offices
>   => [#<Company::Office id: 1, company_id: 1, name: "North America (it's cold out there)", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:25:18">]
{% endcodeblock %}

There are two basic options, that you should know when dealing with `accepts_nested_attributes_for`:

- `allow_destroy` - allows to destroy objects (`false` by default)
- `reject_if` - rejects the records, based on the given  `Proc` or
a `Symbol` pointing to a method. This one is simular to the `Enumerable::reject` method ([Doc](http://www.ruby-doc.org/core-1.9.3/Enumerable.html#method-i-reject)).

Take a look at the other supported options on [apidock.com](http://apidock.com/rails/ActiveRecord/NestedAttributes/ClassMethods/accepts_nested_attributes_for).

### Validating nested attributes

Except the basic validation, you can use `reject_if` option to validate a nested object.

{% codeblock lang:ruby %}
class Company < ActiveRecord::Base
  attr_accessible :name, :offices_attributes
  validates :name, presence: true
  has_many :offices
  accepts_nested_attributes_for :offices, allow_destroy: true, reject_if: :office_name_invalid

  private

    def office_name_invalid(attributes)
      # office name shouldn't start with underscore
      attributes['name'] =~ /\A_/
    end
end
{% endcodeblock %}

The method should return either true (rejects the record) or false.

{% codeblock lang:ruby %}
> c.offices_attributes = [{ id: 1, name: '_North America'}]
>   => [{:id=>1, :name=>"_North America"}]
> c.save
> c.offices # no changes
>   => [#<Company::Office id: 1, company_id: 1, name: "North America", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:46:22">]
{% endcodeblock %}

We could use predefined `:all_blank` symbol.

{% codeblock lang:ruby %}
> c.offices_attributes = [{ name: ''}]
>   => [{:name=>""}]
> c.save
> c.offices # no changes
>   => [#<Company::Office id: 1, company_id: 1, name: "North America", created_at: "2012-10-08 19:21:54", updated_at: "2012-10-08 19:46:22">]
{% endcodeblock %}

Passing `:all_blank` instead of a Proc will create a proc that will reject a record where all the attributes are blank excluding any value for `_destroy`.

### Validating count of the nested attributes

Lets add more complexity to our company model and say for example: it **must have at least one
office** (we usually called it the main office).

{% codeblock lang:ruby %}
class Company < ActiveRecord::Base
  OFFICES_COUNT_MIN = 1

  attr_accessible :name, :offices_attributes
  validates :name, presence: true
  validate do
    check_offices_number
  end
  has_many :offices
  accepts_nested_attributes_for :offices, allow_destroy: true

  private

    def offices_count_valid?
      offices.count >= OFFICES_COUNT_MIN
    end

    def check_offices_number
      unless offices_count_valid?
        errors.add(:base, :offices_too_short, :count => OFFICES_COUNT_MIN)
      end
    end
end
{% endcodeblock %}

The problem here is that accepts_nested_attributes_for call destroy for child
objects **AFTER** validation of the parent object. So the user is able to delete
an office. Of course, later, when the user will try to edit a company,
he/she will get an error - "Company should have at least one office.".

![Flowchart of the validation process](/images/posts/2012-10-08-validating-nested-associations-in-rails/flowchart.png)

{% codeblock lang:ruby %}
> c.offices_attributes = [{ id: 1, _destroy: '1' }]
>   => [{:id=>1, :_destroy=>"1"}]
> c.save
> c.offices
>   => []
{% endcodeblock %}

You could try to use standard `length` validator
(e.g. `validates :offices, length: { minimum: OFFICES_COUNT_MIN }`), and it actually works,
but again, it does not take into account the fact that some of the records may
be marked for destruction.

The things are getting a little tricky here.
To sort out the problem, we need to understand what `offices_attributes=` method does.

{% codeblock lang:ruby %}
# accepts_nested_attributes_for generates for us this method
def offices_attributes=(attributes)
  # @note the name of the method to call may vary depending on the type of association
  # @see https://github.com/rails/rails/blob/master/activerecord/lib/active_record/nested_attributes.rb#L285
  assign_nested_attributes_for_collection_association(:offices, attributes, mass_assignment_options)
end

def assign_nested_attributes_for_collection_association
  ...
  if !call_reject_if(association_name, attributes) # if the record passed
    # update a record with the attributes or marks it for destruction
    assign_to_or_mark_for_destruction(existing_record, attributes, options[:allow_destroy], assignment_opts)
  end
  ...
end
{% endcodeblock %}

As you can see from the code above, our method marks offices records (with `_destroy` attribute) for destruction.
When the company validates offices count, the offices relation includes **all** the records.
So, all we need to do is to select only those records not marked for destruction.

{% codeblock lang:ruby %}
class Company < ActiveRecord::Base
  ...

  private

    def offices_count_valid?
      offices.reject(&:marked_for_destruction?).count >= OFFICES_COUNT_MIN
    end
end
{% endcodeblock %}

Now we've got the actual number of the company's offices. Therefore, we will get an error while trying to delete the last office in North America:

{% codeblock lang:ruby %}
> c.offices_attributes = [{ id: 1, _destroy: '1' }]
>   => [{:id=>1, :_destroy=>"1"}]
> c.save
> c.errors
>   => #<ActiveModel::Errors:0x000000038fc840 @base=#<Company id: 1, name: "Mars LLC", created_at: "2012-10-08 19:16:44", updated_at: "2012-10-08 19:16:44">, @messages={:base=>["Company should have at least one office."]}>
{% endcodeblock %}

Hopefully, in Rails 3 we are now able to write our own custom validators, so I've added [one more for this case](/2012/10/associationcountvalidator).

If you know a better solution, don't hesitate to [contact me](/about.html) or simply leave a comment below.

### Validating presence of the parent object

The last thing I wanna share with you is how you can add `presence` validator
to the parent association inside the nested model.

{% codeblock lang:ruby %}
class Company::Office < ActiveRecord::Base
  attr_accessible :company_id, :name

  validates :name, presence: true
  # add validator to company
  validates :company, presence: true

  belongs_to :company
end
{% endcodeblock %}

We want to be sure that the office always have a corresponding company. But this fails on creating a company.

{% codeblock lang:ruby %}
> c = Company.create(name: 'Adidas America Inc', offices_attributes: [{ name: 'LS' }])
>   => #<Company id: nil, name: "Adidas America Inc", created_at: nil, updated_at: nil>
> c.errors
>   => #<ActiveModel::Errors:0x000000036387a8 @base=#<Company id: nil, name: "Adidas America Inc", created_at: nil, updated_at: nil>, @messages={:"offices.company"=>["can't be blank"]}>
{% endcodeblock %}

The solution here is to use `inverse_of` option. See the options section
in `belongs_to`, `has_one` or `has_many` [documentation](http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/belongs_to).
Note: it does not work in combination with the `polymorphic` option.

{% codeblock lang:ruby %}
class Company < ActiveRecord::Base
  ...
  has_many :offices, inverse_of: :company
  ...
end

class Company::Office < ActiveRecord::Base
  ...
  belongs_to :company, inverse_of: :offices
  ...
end
{% endcodeblock %}

Now we are able to create a company instance:

{% codeblock lang:ruby %}
> c = Company.create(name: 'Adidas America Inc', offices_attributes: [{ name: 'LS' }])
>   => #<Company id: 2, name: "Adidas America Inc", created_at: "2012-10-09 07:36:07", updated_at: "2012-10-09 07:36:07">
> c.offices
>   => #<Company::Office id: 6, company_id: 2, name: "LS", created_at: "2012-10-09 07:36:07", updated_at: "2012-10-09 07:36:07">
{% endcodeblock %}
