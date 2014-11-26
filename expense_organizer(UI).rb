
require 'pg'
require './lib/expenses'
require './lib/categories'
require './lib/expenses_categories'

DB = PG.connect(:dbname => 'expense_organizer')

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
	puts "press 'a' to see all expenses, press 'b' to see only expenses of a certain category, press 'c' to see only expenses above a certain value"
	
end
