require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.



class Relation
	
	attr_accessor :params
	
	def self.params
		@params ||= {}
	end
	
	# Cat.where(owner_id: 1).where(name: "breakfast")
	# return Relation object (ie. self)
	def self.where(params = {})
		@params = self.params.merge(params)
		
		self
	end
	
	def self.inspect
		to_a.inspect
	end
	
	# run the query
	def self.to_a
		where_line = self.params.map{|k, v| "#{k} = ?"}.join(" AND ")
		
		results = DBConnection.execute(<<-SQL, self.params.values)
			SELECT
				*
			FROM
				#{table_name}
			WHERE
				#{where_line}
		SQL
		
		# reset self.params
		@params = {}
		
		results.map do |result|
			self.find(result["id"])
		end
		
	end
	
end


class SQLObject < Relation
  def self.columns
		res = DBConnection.execute2(<<-SQL )
			SELECT
				*
			FROM
				#{table_name}
		SQL
		
		res.first.map(&:to_sym)
	
  end

  def self.finalize!
		# define getters and setters for each column
		self.columns.each do |col|
			define_method(col) do
				self.attributes[col]
			end
			
			define_method("#{col}=") do |val|
				self.attributes[col] = val
			end
		end
  end

  def self.table_name=(table_name)
		@table_name = table_name
  end

  def self.table_name
		@table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL )
			SELECT
				*
			FROM
				#{table_name}
		SQL
		
		parse_all(results)
  end

  def self.parse_all(results)
		results.map do |params|
			self.new(params)
		end
  end

  def self.find(id)
		results = DBConnection.execute(<<-SQL, id)
			SELECT
				*
			FROM
				#{table_name}
			WHERE
				#{table_name}.id = ?
		SQL
		
		results.empty? ? nil : self.new(results.first)
  end

  def initialize(params = {})
		params.each do |attr_name, value|
			if self.class.columns.include?(attr_name.to_sym)
				self.send("#{attr_name}=", value)
			else
				raise "unknown attribute '#{attr_name}'"
			end
		end
  end

  def attributes
		@attributes ||= {}
  end

	#returns an array of the values for each attribute
  def attribute_values
		self.class.columns.map do |col_name|
			self.send(col_name)
		end
  end

  def insert
		col_names = self.class.columns.join(", ")
		question_marks = (["?"] * self.class.columns.size).join(", ")
		
		DBConnection.execute(<<-SQL, *attribute_values)
			INSERT INTO 
				#{self.class.table_name} (#{col_names})
			VALUES
				(#{question_marks})
		SQL
					
		self.id = DBConnection.last_insert_row_id
  end

  def update
		set_line = self.class.columns.map{|col| "#{col} = ?" }.join(", ")
		
		DBConnection.execute(<<-SQL, *self.attribute_values, self.id)
			UPDATE
				#{self.class.table_name} 
			SET
				#{set_line}
			WHERE
				id = ?
		SQL
					
  end

  def save
		self.id.nil? ? insert : update
  end
end
