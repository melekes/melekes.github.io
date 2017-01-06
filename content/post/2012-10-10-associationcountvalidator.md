+++
date = "2012-10-10T00:00:00Z"
draft = false
slug = "associationcountvalidator"
tags = [
  "tutorials",
  "ruby",
  "ruby-on-rails",
  "activerecord",
  "forms",
  "validation",
  "nested-attributes",
  "accepts_nested_attributes_for"
]
title = "AssociationCountValidator"

+++
As a result of my [previous blog post](/2012/10/validating-nested-associations-in-rails)
about validating nested associations, I wrote custom validator for Rails 3.
It is intended to help you to validate records count in a given association.

<!--more-->

``` ruby
# lib/association_count_validator.rb
class AssociationCountValidator < ActiveModel::Validations::LengthValidator
  MESSAGES = { :wrong_length => :association_count_invalid,
               :too_short => :association_count_greater_than_or_equal_to,
               :too_long => :association_count_less_than_or_equal_to }.freeze

  def initialize(options)
    MESSAGES.each { |key, message| options[key] ||= message }
    super
  end

  def validate_each(record, attribute, value)
    existing_records = record.send(attribute).reject(&:marked_for_destruction?)
    super(record, attribute, existing_records)
  end
end
```

Probably, you noticed that this is just a wrapper over the standard `LengthValidator`.
This has a big advantage - all options, provided by the basic validator, are supported.
And it correctly handles the situation with marked for destruction records,
which was mentioned in the previous post.

Usage:

``` ruby
class Company < ActiveRecord::Base
  OFFICES_COUNT_MIN = 1

  attr_accessible :name, :offices_attributes

  validates :name, presence: true
  validates :offices, association_count: { minimum: OFFICES_COUNT_MIN }

  has_many :offices, inverse_of: :company

  accepts_nested_attributes_for :offices, allow_destroy: true
end
```

Do not forget to add custom error messages to your localization files.

Example for `en` culture:

``` yaml
en:
  errors:
    messages:
      association_count_less_than_or_equal_to:
        one: count must be less than 1
        other: count must be less than or equal to %{count}
      association_count_greater_than_or_equal_to:
        one: count must be greater than 1
        other: count must be greater than or equal to %{count}
      association_count_invalid:
        one: count is invalid (must be equal to 1)
        other: count is invalid (must be equal to %{count})
```
