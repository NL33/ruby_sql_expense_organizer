require 'pg'

class Categories
	attr_accessor: :category_name
	attr_reader: :categoryID

def initialize(attributes)
  @category_name = attributes['category_name']
end

def category_name
  @category_name
end


def save
	results = DB.exec("INSERT INTO categories (category_name) 
		VALUES (#{@category_name) RETURNING categoryID;")
	@categoryID = results.first['categoryID'].to_i
end