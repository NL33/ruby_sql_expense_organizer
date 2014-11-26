require ‘pg’

class Expenses
  attr_accessor :expense_name; :expense_price; :expense_date  #attr_accessor allows reading (ie, "retrieve") and writing ("set") the instances
  attr_reader :expenseID #attr_reader allows just reading (cannot manipulate)

 def initialize(attributes)
 	@expense_name = attributes['expense_name']
 	@expense_price = attributes['expense_price']
 	@expense_date = attributes['expense_date']
 	#we translate the database table column/instance in the column into a hash (column value => instance in the column). 
 	#so, when we initialize a new entry, we need to use the hash format.
 	#example of new expense initialize: pizza, bought for $18.50, on October 15, 2014:
 	#pizza = Expenses.new({:expense_name => 'pizza', :expense_price => 18.50, :expense_date => '2014-10-15'})
 end

def expense_name
	@expense_name
end

def expense_price
	@expense_price
end

def expense_date
	@expense_date
end

def expenseID
	@expenseID
end

def save
	results = DB.exec("INSERT INTO expenses (expense_name, expense_price, expense_date) 
		VALUES ('#{@expense_name}', #{@expense_price}, '#{@expense_date}') RETURNING expenseID;")
		#note that DB is created in the expense_organizer UI
		#pizza example from initialize method above: 
		#DB.exec ("INSERT INTO expenses (expense_name, expense_price, expense_date) 
		#  VALUES ('pizza', 18.50, '2014-10-15') RETURNING id;")
		#NOTE: we use the instance variable @ symbol in the method because we are calling the value from the 
		#      other method (the initialize method)--here, @expense_name is the value established for expense_name
		#      in the initialize method.
		#we say "RETURNING id" so in results there is the id value
	@expenseID = results.first['expenseID'].to_i  #this is to give us the list id, which we need to know what should go in the join table
	#first returns the first object of a collection. Here, we get the first hash produced (the only one that there is), and grab the id from it
	#'expenseID' here refers to the column name we want (which is formatted as a key in a hash), and first picks the first from that column (here, because
		#  we are referring to what we just created in the INSERT INTO action, there is only one value. First is a method
		#   to get at that value.)
end

