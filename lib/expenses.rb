require ‘pg’

class Expenses
  attr_accessor :expense_name; :expense_price; :expense_date  #attr_accessor allows reading (ie, "retrieve") and writing ("set") the instances
  attr_reader :expenseID #attr_reader allows just reading (cannot manipulate)

 def initialize(attributes)
 	@expense_name = attributes['expense_name']
 	@expense_price = attributes['expense_price']
 	@expense_date = attributes['expense_date']
 	@category = attributes['category']
 	#we translate the database table column/instance in the column into a hash (column value => instance in the column). 
 	#so, when we initialize a new entry, we need to use the hash format.
 	#example of new expense initialize: pizza, bought for $18.50, on October 15, 2014:
 	#pizza = Expenses.new({:expense_name => 'pizza', :expense_price => 18.50, :expense_date => '2014-10-15', :category => food})
 	#Note: category is actually a separate table (hence a separate class called category.) Included here as well 
 	#  to be accessible through the Expenses class (through the self.all method below) 
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

def category
	@category
end

def save #puts an entry into the database
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
	@expenseID = results.first['expenseID'].to_i  #this is to give us the expenseID (this is the definition of the variable, that links to the expenseID method above)
	#first returns the first object of a collection. Here, we get the first hash produced (the only one that there is), and grab the id from it
	#'expenseID' here refers to the column name we want (which is formatted as a key in a hash), and first picks the first from that column (here, because
		#  we are referring to what we just created in the INSERT INTO action, there is only one value. First is a method
		#   to get at that value.)
end

 def self.all  #puts the entries into the initialize form, enabling standard ruby methods like above (ie, expense.expense_name)
    results = DB.exec("SELECT expenses.expenseID, expense_name, expense_date, expense_price, category_name 
	FROM expenses 
	JOIN expenses_categories ON expenses_categories.expenseID = expenses.expenseID               
	JOIN categories ON categories.categoryID = expenses_categories.categoryID;")
      #NOTES for future reference:
      # This join statement will produce a "table" with columns expenseID, expense_name, expense_date, expense_price, and category_name,
      #   and values for each wherever they had been given (ie, where an expense has been entered and assigned to a category)
      #   the hashes will be read on a loop (such as results.each do |result|) as
      #     (expenseID => 1, expense_name => 'pizza', expense_price => 10.3, expense_date => '2014-11-05', category_name => 'food'),
    		  #    (expenseID => 2, expense_name => 'party hats', ... category_name => 'fun')...]
      #Further NOTE: If wanted simpler display of just expenses, would use:
      #results = DB.exec("SELECT * FROM expenses;")  #this is going to produce a collection of hashes (that, by itself, is not readable)
    		  #example result:
    		  #   (expenseID => 1, expense_name => 'pizza', expense_price => 10.3, expense_date => '2014-11-05'),
    		  #    (expenseID => 2, expense_name => 'monitor', ...)]
    expenses = []
    results.each do |result|
      id = result['expenseID']
      name = result['expense_name'] #each result is a hash. the hash key is name. We grab the value from this key.
      date = result['expense_date']
	  price = result['expense_price']
	  category = result['category_name']
      expenses << Expenses.new(id, name, date, price, category) #here we make a new Doctor with the name and specialty
    end
    expenses
  end
  #NOTE: This self.all method will produce more than one row with the same expense if an expense has been entered more than once into the join table 
	 	#   to represent that expense having multiple categories. To combine into a single row in this case: solutions include CASE THEN (http://www.1keydata.com/sql/sql-case.html also see http://www.techonthenet.com/sql_server/functions/case.php)
	 	 #  Other solutions discussed here: http://dba.stackexchange.com/questions/17921/combine-column-from-multiple-rows-into-single-row 
		#  further solution: http://forums.asp.net/t/1580379.aspx?Multiple+SQL+rows+merge+into+single+row+if+the+id+is+same+ 	

 def ==(another_expense)
    self.name == another_expense.name && self.category == another_expense.category #likely not required for present purposes but included for illustration
 end
end

