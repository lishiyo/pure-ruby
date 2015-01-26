require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options
  # belongs_to :human, :foreign_key => :owner_id
  # has_one_through :home, :human, :house

  def has_one_through(name, through_name, source_name)
		
		define_method(name) do
			# through_obj = self.send(through_name) # cat.human => ned
			# source_obj = through_obj.send(source_name) # ned.send(:house) => ned.house
			
			# Cat.assoc_options[:human] => :owner_id, "Human", :id
			through_options = self.class.assoc_options[through_name] 
			
			# Human.assoc_options[:house] => :house_id, "House", :id
			source_options = through_options.model_class.assoc_options[source_name]
			
			source_table = source_options.table_name # "houses"
			through_table = through_options.table_name # "humans"
			key_val = self.send(through_options.foreign_key)
			
			results = DBConnection.execute(<<-SQL, key_val)
				SELECT
					#{source_table}.*
				FROM
					#{through_table}
				JOIN
					#{source_table} 
				ON 
					#{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
				WHERE
					#{through_table}.#{through_options.primary_key} = ?
			SQL
			
			# House.new(params)
			source_obj = source_options.model_class.parse_all(results).first
			
			source_obj
		end
		
  end
	
	# House.has_many :cats, through: :humans, source: :cats
	def has_many_through(name, through_name, source_name)
		
		define_method(name) do
			
			# House.assoc_options[:humans] => :house_id, "Human", :id
			through_options = self.class.assoc_options[through_name]
			# Human.assoc_options[:cats] => :owner_id, "Cat", :id
			source_options = through_options.model_class.assoc_options[source_name]

			through_table = through_options.table_name # "humans"
			source_table = source_options.table_name # "cats"
			key_val = self.send(through_options.primary_key)

			results = DBConnection.execute(<<-SQL, key_val )
				SELECT
					#{source_table}.*
				FROM
					#{through_table}
				INNER JOIN
					#{source_table}
				ON
					#{source_table}.#{source_options.foreign_key} = #{through_table}.#{through_options.primary_key}
				WHERE
					#{through_table}.#{through_options.foreign_key} = ?
			SQL
			
			# Cat.new(results) => array of Cats
			source_options.model_class.parse_all(results)
		end
	end
	
	
	# Cat.includes(:human).limit(10)
	# SELECT * FROM cats LIMIT 10
	# SELECT humans.* FROM humans WHERE humans.id IN (selected cats.owner_id..)
	def includes(assoc)
		
		# Cat.assoc_options[:human] => :owner_id, "Human", :id
		inc_options = self.assoc_options[assoc]
		
		base_query = DBConnection.execute(<<-SQL)
			SELECT
				*
			FROM
				#{table_name}
		SQL
		
		# [ 1, 2, 3 ]
		selected_ids = base_query.map{|hash| hash[inc_options.foreign_key.to_s] }.uniq.compact.join(", ")
		
		includes_query = (<<-SQL)
			SELECT
				#{inc_options.table_name}.*
			FROM
				#{inc_options.table_name}
			WHERE
				#{inc_options.table_name}.id IN (#{selected_ids})
		SQL
		
		total_query = DBConnection.execute(<<-SQL)
			SELECT
				#{table_name}.*, included.*
			FROM
				#{table_name}
			LEFT JOIN
				(#{includes_query}) 
			AS 
				included
			ON
				#{table_name}.#{inc_options.foreign_key} = included.#{inc_options.primary_key}
		SQL
		
	end
	
end



class Cat < SQLObject
	belongs_to :human, foreign_key: :owner_id
	
	finalize! 
end


class Human < SQLObject
	self.table_name = 'humans'

	has_many :cats, foreign_key: :owner_id
	belongs_to :house

	finalize!
end

class House < SQLObject
	has_many :humans
	has_many_through :resident_cats, :humans, :cats

	finalize!
end
