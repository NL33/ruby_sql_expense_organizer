require 'pg'

class Expenses_categories
	attr_accessor: :expenseID, :categoryID
	attr_reader: :joinID

def initialize(attributes)
  @expenseID = attributes['expenseID']
  @categoryID = attributes['categoryID']
end

def expenseID
  @expenseID
end

def categoryID
  @categoryID
end

def save
	results = DB.exec("INSERT INTO expenses_categories (expenseID, categoryID) 
		VALUES (#{@expenseID}, #{categoryID}) RETURNING joinID;")
	@joinID = results.first['joinID'].to_i
end