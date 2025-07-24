Little Lemon is a family-owned Mediterranean restaurant. They are developing a MySQL database so that the bookings, customers, staff, menus and orders information can be stored in their respective tables.
The restaurant owner wants to use the stored data to make data-driven decisions to increase their revenue. Establishing a database is one of their key objectives.
The goal of the project is to build a MySQL database system for Little Lemon restaurant, allowing them to store data regarding:
•	Bookings - To store information about booked tables in the restaurant including booking id, date and table number.
•	Orders - To store information about booked tables in the restaurant including booking id, date and table number.
•	Order delivery status - To store information about the delivery status of each order such as delivery date and status.
•	Menu - To store information about cuisines, starters, courses, drinks and desserts.
•	Customer details - To store information about the customer names and contact details.
•	Staff information - Including role and salary.
You are provided with the following materials for this project:
•	Data Model
•	Datasets (csv files) for each table
TASKS
Task 1: Retrieve all customers from the United States (country_code = 'US') sorted by last name in ascending order.
Task 2: Find all orders placed in the last 30 days with a quantity greater than 1, displaying order_id, order_date, and total cost (cost * quantity).
Task 3: Update the salary of all staff with the role 'Manager' to be 10% higher than their current salary.
Task 4: Delete all bookings that are more than 1 year old and were made by customers who haven't placed any orders.
Task 5: Calculate the average preparation time for each course type (starter, main course, dessert) across all menus.
Task 6: Show the total sales (sum of cost) for each month of the current year, including only months with sales over $5000.
Task 7: Find the most popular menu item (based on order count) for each cuisine type.
Task 8: Display the customer who has spent the most at the restaurant, showing their full name and total spending.
Task 9: Create a report showing all orders with their corresponding menu items (from all categories: starters, courses, etc.) using appropriate joins.
Task 10: Find customers who have made bookings but never placed an order, using a set operation.
Task 11: Create a view that shows staff performance metrics including number of orders taken, total sales generated, and average order value.
Task 12: Write a stored procedure that takes a date range and returns the busiest times of day (based on booking counts) during that period.
Task 13: Create a trigger that automatically updates the delivery status to 'Preparing' when a new order is inserted.
Task 14: Find all bookings for Fridays or Saturdays that are after 6 PM.
Task 15: Extract the year and month from order dates and group sales by these periods.
Task 16: Rank staff members by their total sales within each role (waitstaff, manager, etc.).
Task 17: For each customer, show their order history along with how much more or less they spent compared to their previous order.
Task 18: Calculate a 3-month moving average of sales for the restaurant.
Task 19: Write a query using CASE to categorize orders as 'Small' (<$50), 'Medium' ($50-$100), or 'Large' (>$100).
Task 20: Create an index that would optimize queries searching for orders by customer_id and order_date.
Task 21: Rewrite one of your complex queries using a CTE instead of subqueries and explain the benefits.
Task 22: Use a recursive CTE to find all possible menu combinations where the total preparation time is under 30 minutes.
Task 23: Analyze sales growth by comparing each month's sales to the same month in the previous year using window functions.
Task 24: Create a comprehensive report that combines data from all tables to show restaurant performance metrics, including:
•	Customer acquisition and retention rates
•	Table turnover rates
•	Menu item profitability
•	Staff productivity
Task 25: Create a virtual table called OrdersView that focuses on OrderID, Quantity and Cost columns within the Orders table for all orders with a quantity greater than 2.
Task 26:
Create a prepared statement called GetOrderDetail. This prepared statement will help to reduce the parsing time of queries. It will also help to secure the database from SQL injections.
The prepared statement should accept one input argument, the CustomerID value, from a variable. The statement should return the order id, the quantity and the order cost from the Orders table.
Task 27:
Create a stored procedure called CancelOrder. Little Lemon want to use this stored procedure to delete an order record based on the user input of the order id.
Creating this procedure will allow Little Lemon to cancel any order by specifying the order id value in the procedure parameter without typing the entire SQL delete statement.
Task 28:
Create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked. The procedure should have two input parameters in the form of booking date and table number.
Task 29:
Verify a booking, and decline any reservations for tables that are already booked under another name. Create a new procedure called AddValidBooking. This procedure must use a transaction statement to perform a rollback if a customer reserves a table that’s already booked under another name. 
Task 30:
Create a new procedure called AddBooking to add a new table booking record.
The procedure should include four input parameters in the form of the following bookings parameters:
•	booking id,
•	customer id,
•	booking date,
•	and table number.
Task 31:
Create a new procedure called UpdateBooking that they can use to update existing bookings in the booking table.
The procedure should have two input parameters in the form of booking id and booking date. You must also include an UPDATE statement inside the procedure.

Task 32:
Create a new procedure called CancelBooking that they can use to cancel or remove a booking. The procedure should have one input parameter in the form of booking id. You must also write a DELETE statement inside the procedure.

