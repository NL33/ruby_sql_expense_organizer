
require 'pg'
require './lib/expenses'
require './lib/categories'
require './lib/expenses_categories'

DB = PG.connect(:dbname => 'expense_organizer')

def main_menu
	puts "Welcome to the Expense Organizer"
	puts "Press 'a' to enter an expense, press 'b' to show your expenses (including to see all expenses, 
		expenses only of a certain category, expenses of a certain value, or to search your expenses),
		 or press 'c' to see how much you are spending per category."
	if gets.chomp == 'a'
	 add_expense
	elsif gets.chomp == 'b'
	 show_expenses
	elsif gets.chomp == 'c'
	 sum_category
	else
	 puts "Please enter a valid option"
	 main_menu
	end
end


def add_expense
	puts "Please enter the name of the expense"
	 name_entry = gets.chomp
	puts "please enter the amount of the expense"
	 price_entry = gets.chomp
	puts "Please enter the date of the expense (YYYY-MM-DD)"
	 date_entry = gets.chomp
	 new_expense = Expenses.new({:expense_name => name_entry, :expense_price => price_entry, :expense_date => date_entry})
	 new_expense.save

	puts "Please enter a category for this expense"
	 category_entry = gets.chomp
	 new_category = Categories.new({:category_name => category_entry})
	 new_category.save
	
	new_join_entry = Expenses_categories.new({:expenseID => new_expense.expenseID, :categoryID => new_category.categoryID })
	new_join_entry.save
	
	puts "Would you like to enter another category for this expense? (Y/N)"
	loop do
		if gets.chomp = 'y'
		 puts "Please enter the name of the additional category for this expense"
		   additional_category_entry = gets.chomp
		   additional_category = Categories.new({:category_name => additional_entry})
		   additional_category.save
		
		   additional_join_entry = Expenses_categories.new({:expenseID => new_expense.expenseID, :categoryID => additional_category.categoryID })
		   additional_join_entry.save
	     puts "Additional category saved."

	    elsif gets.chomp == 'n'
	     break
	    end
     end
	elsif gets.chomp = 'n'
		main_menu
	end
		
	puts "Your expense has been added!"
	main_menu
end

def show_expenses
	puts "press 'a' to see all expenses, press 'b' to see only expenses of a certain category, 
	      press 'c' to see only expenses above a certain value, or 'd' to search for an expense"
	 if gets.chomp == 'a' #view all expenses. Note that the Expenses.all method is probably not strictly necessary. Steps like those in the other options below would likely suffice. The self.All method is left in as an example. 
	 	  Expenses.all.each do |expense|
	 		puts "ID:" + expense.expenseID + "|" + "Name:" + expense.expense_name + "|" + 
	 			   "Date:" + expense.expense_date + "|" + "Amount" + expense.expense_price + "|" +
	 			   "Category"
	 	  end
	  main_menu
	 end  	
	 elsif gets.chomp == 'b' #search for all expenses of a certain category
		 loop do
		  puts "Select the category to view" 
		  	selected_category = gets.chomp
		  	  results = DB.exec("SELECT expenses.expenseID, expense_name, expense_date, expense_price
								FROM expenses 
								JOIN expenses_categories on expenses_categories.expenseID = expenses.expenseID               
								JOIN categories on categories.categoryID = expenses_categories.categoryID 
								WHERE categories.category_name = selected_category;")
			  results.each do |result|
			  	 puts "#{result['expenses.expenseID']} | #{result['expense_name']} | #{result['expense_date']} | #{result['expense_price']}" 
			  end
			  puts "Press 'a' to view another category, or 'b' to return to the main menu"
			  if gets.chomp == 'b'
			  	break
			  	main_menu
			  end
		elsif gets.chomp == 'c' #search for amounts only of a certain level
		  loop do
			  puts "enter an amount"
			  amount_entry = gets.chomp
			  results = DB.exec("SELECT expenses.expenseID, expense_name, expense_date, expense_price, category_name 
					FROM expenses 
					JOIN expenses_categories ON expenses_categories.expenseID = expenses.expenseID               
					JOIN categories ON categories.categoryID = expenses_categories.categoryID 
					WHERE expense_price >= amount_entry;")
			  results.each do |result|
				  	 puts "#{result['expenses.expenseID']} | #{result['expense_name']} | #{result['expense_date']} | #{result['expense_price']}" 
			  end
			  puts "Press 'a' to view another amount, or 'b' to return to the main menu"
			  if gets.chomp == 'b'
			  	break
			  	main_menu
			  end
	      end
	    elsif gets.chomp == 'd' #search for an expense
	       loop do
	       	  puts "enter an expense to search for"
	       	  expense_entry = gets.chomp
	       	   results = DB.exec("SELECT expenses.expenseID, expense_name, expense_date, expense_price, category_name 
					FROM expenses 
					JOIN expenses_categories ON expenses_categories.expenseID = expenses.expenseID               
					JOIN categories ON categories.categoryID = expenses_categories.categoryID 
					WHERE expense_name = expense_name;")
			    results.each do |result|
				  	 puts "#{result['expenses.expenseID']} | #{result['expense_name']} | #{result['expense_date']} | #{result['expense_price']}" 
			    end
			  puts "Press 'a' to view another amount, or 'b' to return to the main menu"
			  if gets.chomp == 'b'
			  	break
			  	main_menu
			  end
	      end
	    end
     end

def sum_category  #see how much spent in each category
	loop do
		puts "enter the category you would like to calculate"
		category_entry = gets.chomp
		result = DB.exec("SELECT SUM(expense_price) FROM expenses
		JOIN expenses_categories ON expenses_categories.expenseID = expenses.expenseID               
		JOIN categories ON categories.categoryID = expenses_categories.categoryID
		WHERE categories.category_name = selected_category;") 
		puts result.first['sum'].to_f
 	     puts "Press 'a' to view another category, or 'b' to return to the main menu"
	 if gets.chomp == 'b'
		break
		main_menu
	 end
end
	
end
