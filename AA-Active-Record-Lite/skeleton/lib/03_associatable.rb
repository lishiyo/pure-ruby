require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
		self.class_name.constantize
  end

  def table_name
		model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
		@foreign_key = options[:foreign_key] || name.to_s.singularize.underscore.concat("_id").to_sym
		@primary_key = options[:primary_key] || :id
		@class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
		@foreign_key = options[:foreign_key] || self_class_name.to_s.singularize.underscore.concat("_id").to_sym
		@primary_key = options[:primary_key] || :id
		@class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  # Within belongs_to, call define_method to create a new method to access the association. Within this method:
# Use send to get the value of the foreign key.
# Use model_class to get the target model class.
# Use where to select those models where the primary_key column is equal to the foreign key value.
# Call first (since there should be only one such item).
  def belongs_to(name, options = {})
		# Cat.belongs_to(:owner, class_name: "Human", foreign_key: :owner_id)
		assoc_options[name] = BelongsToOptions.new(name, options)
		options = assoc_options[name]
		# define method creates instance method #human
		define_method(name) do
			foreign_key_val = self.send(options.foreign_key) # breakfast.owner_id
			target_class = options.model_class # "Human"
			# Human.where(id: 1)
			target_class.where({ options.primary_key => foreign_key_val}).first
		end
  end

  def has_many(name, options = {})
		# options = HasManyOptions.new(name, self.name, options)
		assoc_options[name] = HasManyOptions.new(name, self.name, options)
		options = assoc_options[name]
		# define method creates instance method #cats
		define_method(name) do
			primary_key_val = self.send(options.primary_key) # ned.send(:id)
			target_class = options.model_class # "Cat"
			# Cat.where({ :owner_id => 1})
			target_class.where({options.foreign_key => primary_key_val})
		end
  end

  def assoc_options
   	@assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
	extend Associatable
end
