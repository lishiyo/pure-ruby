require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
	
  def where(params)
		where_line = params.map{|k, v| "#{k} = ?"}.join(" AND ")
		
		results = DBConnection.execute(<<-SQL, params.values)
			SELECT
				*
			FROM
				#{table_name}
			WHERE
				#{where_line}
		SQL
		
		results.map do |res|
			self.find(res["id"])
		end
  end
end


class SQLObject < Relation
	# extend Searchable
end
