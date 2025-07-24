-- TASKS
-- Task 1: Retrieve all customers from the United States (country_code = 'US') sorted by last name in ascending order.
USE LittleLemonDB;
SELECT 
	customer_last_name,
	country_code
FROM customers
WHERE country_code = "US" 
ORDER BY 1;

-- Task 2: Find all orders placed in the last 30 days with a quantity greater than 1, 
-- displaying order_id, order_date, and total cost (cost * quantity).
 
SELECT 
    order_id,
    order_date,
    cost * quantity AS total_cost
FROM 
    orders
WHERE 
    quantity > 1
    AND order_date BETWEEN (
        SELECT DATE_SUB(MAX(order_date), INTERVAL 30 DAY)
        FROM orders
    ) AND (
        SELECT MAX(order_date)
        FROM orders
    );
    
-- Task 3: Update the salary of all staff with the role 'Manager' to be 10% higher than their current salary.
-- turn off safe update mode
SET SQL_SAFE_UPDATES = 0;
-- update the Manager's salary
UPDATE staff
SET staff_salary = staff_salary * 1.10
WHERE staff_role = 'Manager';

-- Task 4: Delete all bookings that are more than 1 year old and were made by customers who haven't placed any orders.
SELECT *
FROM bookings
WHERE booking_date < (
    SELECT MAX(booking_date) - INTERVAL 1 YEAR
    FROM bookings
)
AND booking_customer_id NOT IN (
    SELECT DISTINCT order_customer_id
    FROM orders
    WHERE order_customer_id IS NOT NULL
);

-- Task 5: Calculate the average preparation time for each course type (starter, main course, dessert) across all menus.

SELECT
  'starter' AS course_type,
  SEC_TO_TIME(AVG(TIME_TO_SEC(s.prep_time))) AS avg_prep_time
FROM menus m
JOIN starters s ON m.starter = s.name

UNION ALL

SELECT
  'course' AS course_type,
  SEC_TO_TIME(AVG(TIME_TO_SEC(c.prep_time))) AS avg_prep_time
FROM menus m
JOIN courses c ON m.course = c.name

UNION ALL

SELECT
  'dessert' AS course_type,
  SEC_TO_TIME(AVG(TIME_TO_SEC(d.prep_time))) AS avg_prep_time
FROM menus m
JOIN desserts d ON m.dessert = d.name;

-- Task 6: Show the total sales (sum of cost) for each month of the current year, including only months with sales over $5000.

SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales) AS total_sales,
    SUM(cost) AS total_cost
FROM orders
GROUP BY 
    YEAR(order_date), MONTH(order_date)
HAVING 
    total_sales > 5000
ORDER BY 
    year, month;

-- Task 7: Find the most popular menu item (based on order count) for each cuisine type.
     SELECT cuisine, menu_name, order_count
FROM (
  SELECT
    m.cuisine,
    m.menu_name,
    COUNT(o.order_id) AS order_count,
    RANK() OVER (PARTITION BY m.cuisine ORDER BY COUNT(o.order_id) DESC) AS rank_within_cuisine
  FROM orders o
  JOIN menus m ON o.menu_name = m.menu_name
  GROUP BY m.cuisine, m.menu_name
) AS menu_order_counts
WHERE rank_within_cuisine = 1;
-- Task 8: Display the customer who has spent the most at the restaurant, showing their full name and total spending.

SELECT
CONCAT(customer_first_name,' ', customer_last_name) AS Full_Name,
SUM(o.sales) AS total_spent
FROM orders o
JOIN customers c ON o.order_customer_id = c.customer_id
GROUP BY CONCAT(customer_first_name,' ', customer_last_name)
ORDER BY SUM(o.sales) DESC;

/* Task 9: Create a report showing all orders with their corresponding 
 menu items (from all categories: starters, courses, etc.) using appropriate joins. */
 
SELECT 
    o.order_id,
    o.order_date,
    o.order_customer_id,
    o.order_staff_id,
    o.menu_name,
    s.name AS starter,
    c.name AS course,
    d.name AS dessert,
    dr.name AS drink,
    si.name AS side
FROM orders o
LEFT JOIN 
    menus m ON o.menu_name = m.menu_name
LEFT JOIN 
   starters s ON m.starter = s.name
LEFT JOIN 
   courses c ON m.course = c.name
LEFT JOIN 
  desserts d ON m.dessert = d.name
LEFT JOIN 
  drinks dr ON m.drink = dr.name
LEFT JOIN 
    sides si ON m.side = si.name
ORDER BY 
    o.order_date, o.order_id;
    
-- Task 10: Find customers who have made bookings but never placed an order, using a set operation.

SELECT 
order_id,
customer_id
FROM customers c
JOIN bookings b ON c.customer_id = b.booking_customer_id
LEFT JOIN orders o ON c.customer_id = o.order_customer_id
WHERE o.order_id IS NULL;

-- Task 11: Create a view that shows staff performance metrics including number of orders taken, 
-- total sales generated, and average order value.

CREATE VIEW staff_performance_metrics AS
SELECT 
    o.order_staff_id AS staff_id,
    CONCAT(staff_first_name, ' ', staff_last_name) AS Full_name,
    COUNT(o.order_id) AS number_of_orders,
    SUM(o.sales) AS total_sales,
    SUM(o.sales) / COUNT(o.order_id) AS average_order_value
FROM 
    orders o
JOIN 
    staff s ON o.order_staff_id = s.staff_id
GROUP BY 
    o.order_staff_id;

SELECT * FROM staff_performance_metrics;

/* Task 12: Write a stored procedure that takes a date range and returns the busiest times of day (based on booking counts) 
 during that period.*/

DELIMITER $$

CREATE PROCEDURE GetBusiestBookingTimes()
BEGIN
    DECLARE min_date DATE;
    DECLARE max_date DATE;

    -- Get the min and max booking dates from the bookings table
    SELECT MIN(booking_date), MAX(booking_date)
    INTO min_date, max_date
    FROM bookings;

    -- Return booking counts grouped by hour within the full date range
    SELECT 
        HOUR(booking_time) AS booking_hour,
        COUNT(*) AS total_bookings,
        min_date AS start_date,
        max_date AS end_date
    FROM 
        bookings
    WHERE 
        booking_date BETWEEN min_date AND max_date
    GROUP BY 
        booking_hour
    ORDER BY 
        total_bookings DESC;
END$$

DELIMITER ;

CALL GetBusiestBookingTimes();

-- Task 13: Create a trigger that automatically updates the delivery status to 'Preparing' when a new order is inserted.
SELECT* FROM deliveries;

DELIMITER //

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO deliveries (delivery_date, delivery_status, order_id, delivery_cost)
  VALUES (CURDATE(), 'Preparing', NEW.order_id, 0.00);
END;
//

DELIMITER ;

SHOW TRIGGERS FROM LittleLemonDB;

-- Task 14: Find all bookings for Fridays or Saturdays that are after 6 PM.

SELECT *
FROM bookings
WHERE DAYOFWEEK(booking_date) IN (6, 7)
  AND HOUR(booking_time) >= 18;

-- Task 15: Extract the year and month from order dates and group sales by these periods.
SELECT 
  YEAR(order_date) AS order_year,
  MONTH(order_date) AS order_month,
  SUM(sales) AS monthly_sales
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- Task 16: Rank staff members by their total sales within each role (waitstaff, manager, etc.).
SELECT * FROM orders;
SELECT * FROM staff;

SELECT 
    s.staff_id,
    s.staff_first_name,
    s.staff_last_name,
    s.staff_role,
    SUM(o.sales) AS total_sales,
    RANK() OVER (PARTITION BY s.staff_role ORDER BY SUM(o.sales) DESC) AS sales_rank_within_role
FROM 
	staff s
LEFT JOIN 
	orders o ON s.staff_id = o.order_staff_id
GROUP BY 
    s.staff_id, s.staff_first_name, s.staff_last_name, s.staff_role
ORDER BY 
    s.staff_role, 
    sales_rank_within_role;
    
-- Task 17: For each customer, show their order history along with how much more or less they spent compared to their previous order.

SELECT 
  DISTINCT o.order_customer_id AS customer_id,
  o.order_id,
  o.order_date,
  o.sales AS current_order_sales,
  LAG(o.sales) OVER (PARTITION BY o.order_customer_id ORDER BY o.order_date) AS previous_order_sales,
  (o.sales - LAG(o.sales) OVER (PARTITION BY o.order_customer_id ORDER BY o.order_date)) AS difference_from_previous
FROM 
  LittleLemonDB.orders o
WHERE 
  o.order_customer_id IS NOT NULL
ORDER BY 
  o.order_customer_id,
  o.order_date;
  
-- Task 18: Calculate a 3-month moving average of sales for the restaurant.

WITH MonthlySales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sales) AS total_sales
    FROM 
        orders
    GROUP BY YEAR(order_date), MONTH(order_date)
    ORDER BY year, month
)
SELECT 
    year,
    month,
    total_sales,
    ROUND(AVG(total_sales) OVER (ORDER BY year, month ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ),2) AS three_month_moving_avg
FROM 
    MonthlySales;
    
    -- Task 19: Write a query using CASE to categorize orders as 'Small' (<$50), 'Medium' ($50-$100), or 'Large' (>$100).
    SELECT * FROM orders;
     SELECT
     order_id,
     sales,
     CASE 
	WHEN sales < 50 THEN "small"
	WHEN sales BETWEEN 50 AND 100 THEN "medium"
	ELSE "large"
    END AS sale_category
     FROM orders;
     
     -- Task 20: Create an index that would optimize queries searching for orders by customer_id and order_date.
     CREATE INDEX idx_customer_date
     ON orders(order_customer_id, order_date);
     
-- Task 21: Rewrite one of your complex queries using a CTE instead of subqueries and explain the benefits.
     -- from task 7 using subquery
     SELECT cuisine, menu_name, order_count
FROM (
  SELECT
    m.cuisine,
    m.menu_name,
    COUNT(o.order_id) AS order_count,
    RANK() OVER (PARTITION BY m.cuisine ORDER BY COUNT(o.order_id) DESC) AS rank_within_cuisine
  FROM orders o
  JOIN menus m ON o.menu_name = m.menu_name
  GROUP BY m.cuisine, m.menu_name
) AS menu_order_counts
WHERE rank_within_cuisine = 1;

-- task 7 using CTE
WITH menu_order_counts AS (
  SELECT
    m.cuisine,
    m.menu_name,
    COUNT(o.order_id) AS order_count,
    RANK() OVER (PARTITION BY m.cuisine ORDER BY COUNT(o.order_id) DESC) AS rank_within_cuisine
  FROM
    orders o
  JOIN
    menus m ON o.menu_name = m.menu_name
  GROUP BY
    m.cuisine, m.menu_name
)
SELECT
  cuisine,
  menu_name,
  order_count
FROM
  menu_order_counts
WHERE
  rank_within_cuisine = 1;
  
  /*Advantages of CTE over subquery
-- More readable and maintainable as they Makes complex queries easier to understand.
-- Reusable – Can be referenced multiple times in the same query.
-- Supports recursion – Useful for hierarchical data queries.
-- Simplifies complex logic – Enables step-by-step query building.
-- May improve performance – Avoids repeating the same logic multiple times.
*/
-- Task 22: Use a recursive CTE to find all possible menu combinations where the total preparation time is under 30 minutes.
 
    WITH RECURSIVE MenuCombinations AS (
    -- Base case: Start with all starters STEP 0
    SELECT 
        s.name AS starter,
        CAST(NULL AS CHAR(50)) AS course,
        CAST(NULL AS CHAR(50)) AS dessert,
        CAST(NULL AS CHAR(50)) AS side,
        CAST(NULL AS CHAR(50)) AS drink,
        s.prep_time AS total_prep_time
    FROM starters s
   
    UNION ALL 
     -- Add courses -- STEP 1
    SELECT 
        mc.starter,
        c.name AS course,
        mc.dessert,
        mc.side,
        mc.drink,
        ADDTIME(mc.total_prep_time, c.prep_time)
    FROM MenuCombinations mc
    JOIN LittleLemonDB.courses c
    WHERE mc.course IS NULL AND ADDTIME(mc.total_prep_time, c.prep_time) < '00:30:00'

    UNION ALL

    -- Add desserts -- STEP 2
    SELECT 
        mc.starter,
        mc.course,
        d.name AS dessert,
        mc.side,
        mc.drink,
        ADDTIME(mc.total_prep_time, d.prep_time)
    FROM MenuCombinations mc
    JOIN LittleLemonDB.desserts d
    WHERE mc.dessert IS NULL AND ADDTIME(mc.total_prep_time, d.prep_time) < '00:30:00'

    UNION ALL

    -- Add sides -- STEP 3
    SELECT 
        mc.starter,
        mc.course,
        mc.dessert,
        si.name AS side,
        mc.drink,
        ADDTIME(mc.total_prep_time, si.prep_time)
    FROM MenuCombinations mc
    JOIN LittleLemonDB.sides si
    WHERE mc.side IS NULL AND ADDTIME(mc.total_prep_time, si.prep_time) < '00:30:00'

    UNION ALL

    -- Add drinks -- STEP 4
    SELECT 
        mc.starter,
        mc.course,
        mc.dessert,
        mc.side,
        dr.name AS drink,
        ADDTIME(mc.total_prep_time, dr.prep_time)
    FROM MenuCombinations mc
    JOIN LittleLemonDB.drinks dr
    WHERE mc.drink IS NULL AND ADDTIME(mc.total_prep_time, dr.prep_time) < '00:30:00'
)

-- Final output
SELECT 
    starter,
    course,
    dessert,
    side,
    drink,
    total_prep_time
FROM MenuCombinations
WHERE starter IS NOT NULL
  AND course IS NOT NULL
  AND dessert IS NOT NULL
  AND side IS NOT NULL
  AND drink IS NOT NULL
  AND total_prep_time < '00:30:00'
ORDER BY total_prep_time;

-- Task 23: Analyze sales growth by comparing each month's sales to the same month in the previous year using window functions

SELECT 
YEAR(order_date) AS year_,
MONTH(order_date) AS month_,
SUM(sales) AS total_sales,
LAG(SUM(sales)) OVER (PARTITION BY MONTH(order_date) ORDER BY YEAR(order_date) ROWS BETWEEN 1 PRECEDING AND CURRENT ROW ) AS prev_month,
SUM(sales)-LAG(SUM(sales)) OVER (PARTITION BY MONTH(order_date) ORDER BY YEAR(order_date) ROWS BETWEEN 1 PRECEDING AND CURRENT ROW ) AS monthly_sales_growth
FROM orders
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);

/* Task 24: Create a comprehensive report that combines data from all tables to show restaurant performance metrics, including:
•	Customer acquisition and retention rates
•	Table turnover rates
•	Menu item profitability
•	Staff productivity */

-- Customer Acquisition and Retention
WITH customer_orders AS (
  SELECT
    o.order_customer_id,
    MONTH(o.order_date) AS order_month
  FROM orders o
  WHERE o.order_customer_id IS NOT NULL
),
acquisition AS (
  SELECT
    order_month,
    COUNT(DISTINCT order_customer_id) AS new_customers
  FROM customer_orders
  GROUP BY order_month
),
retention AS (
  SELECT
    order_customer_id,
    COUNT(DISTINCT order_month) AS months_active
  FROM customer_orders
  GROUP BY order_customer_id
)
SELECT
  a.order_month,
  a.new_customers,
  COUNT(r.order_customer_id) AS retained_customers
FROM acquisition a
LEFT JOIN retention r
  ON r.months_active > 1
GROUP BY a.order_month, a.new_customers
ORDER BY a.order_month;

-- Table Turnover Rate
SELECT
  table_no,
  booking_date,
  COUNT(*) AS bookings_count
FROM bookings
GROUP BY table_no, booking_date
ORDER BY booking_date, table_no;

-- Menu Item Profitability
SELECT 
    m.menu_name,
    m.cuisine,
    SUM(o.sales - o.cost) AS total_profit
FROM menus m
JOIN orders o ON m.menu_name = o.menu_name
GROUP BY m.menu_name, m.cuisine
ORDER BY total_profit DESC;


-- staff productivity
SELECT 
staff_id,
CONCAT(staff_first_name, " ", staff_last_name) AS full_name,
COUNT(order_id)AS total_orders,
SUM(sales) AS total_sales
FROM orders o
JOIN staff s ON o.order_staff_id = s.staff_id
GROUP BY staff_id
ORDER BY SUM(sales) DESC;

-- Task 25: Create a virtual table called OrdersView that focuses on OrderID, 
-- Quantity and Cost columns within the Orders table for all orders with a quantity greater than 2.
CREATE VIEW OrdersView AS 
SELECT
	order_id,
	quantity,
	cost
FROM orders
WHERE quantity >2;

SELECT* FROM OrdersView ;

/*Task 26:Create a prepared statement called GetOrderDetail. This prepared statement will help to reduce the parsing time of queries. 
It will also help to secure the database from SQL injections.The prepared statement should accept one input argument, the CustomerID value, 
from a variable. The statement should return the order id, the quantity and the order cost from the Orders table.*/

PREPARE GetOrderDetail FROM
'SELECT order_id, quantity, cost
 FROM LittleLemonDB.orders
 WHERE order_customer_id = ?';
 
 SET @customer_id = '11-253-6502';

EXECUTE GetOrderDetail USING @customer_id;
 
 SELECT * FROM orders;
 
 /* Task 27:
Create a stored procedure called CancelOrder. Little Lemon want to use this stored procedure to delete 
an order record based on the user input of the order id.
Creating this procedure will allow Little Lemon to cancel any order by specifying the order id value in 
the procedure parameter without typing the entire SQL delete statement.
*/

DELIMITER //

CREATE PROCEDURE AddValidBooking (
    IN input_booking_date DATE,
    IN input_table_no INT,
    IN input_customer_id CHAR(11),
    IN input_booking_time TIME
)
BEGIN
    START TRANSACTION;

    -- Check if the table is already booked on that date
    IF EXISTS (
        SELECT 1
        FROM LittleLemonDB.bookings
        WHERE booking_date = input_booking_date
          AND table_no = input_table_no
    ) THEN
        -- Table is already booked → cancel the operation
        ROLLBACK;
    ELSE
        -- Table is available → insert the booking
        INSERT INTO LittleLemonDB.bookings (
            table_no,
            booking_date,
            booking_time,
            booking_customer_id
        )
        VALUES (
            input_table_no,
            input_booking_date,
            input_booking_time,
            input_customer_id
        );

        COMMIT;
    END IF;
END //

DELIMITER ;

CALL AddValidBooking('date', "table", 'customer_id', 'time');

/*Task 28: Create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked.
 The procedure should have two input parameters in the form of booking date and table number.*/
DELIMITER //

CREATE PROCEDURE CheckBooking(
    IN input_date DATE,
    IN input_table INT
)
BEGIN
    SELECT booking_id, booking_time, booking_customer_id
    FROM LittleLemonDB.bookings
    WHERE booking_date = input_date AND table_no = input_table;
END //

DELIMITER ;

CALL CheckBooking('2019-06-14', 9);

-- Task 29: Verify a booking, and decline any reservations for tables that are already booked under another name. Create a new procedure called AddValidBooking. This procedure must use a transaction statement to perform a rollback if a customer reserves a table that’s already booked under another name. 


DELIMITER //

CREATE PROCEDURE AddValidBooking (
    IN input_booking_date DATE,
    IN input_table_no INT,
    IN input_customer_id CHAR(11),
    IN input_booking_time TIME
)
BEGIN
    START TRANSACTION;

    -- Check if the table is already booked on that date
    IF EXISTS (
        SELECT 1
        FROM LittleLemonDB.bookings
        WHERE booking_date = input_booking_date
          AND table_no = input_table_no
    ) THEN
        -- Table is already booked → cancel the operation
        ROLLBACK;
    ELSE
        -- Table is available → insert the booking
        INSERT INTO LittleLemonDB.bookings (
            table_no,
            booking_date,
            booking_time,
            booking_customer_id
        )
        VALUES (
            input_table_no,
            input_booking_date,
            input_booking_time,
            input_customer_id
        );

        COMMIT;
    END IF;
END //

DELIMITER ;

-- if you want to confirm a reservation has been made, use the query:

CALL AddValidBooking('2021-04-26', 3, '13-040-2063', '20:00:00');

/* Task 30:
Create a new procedure called AddBooking to add a new table booking record.
The procedure should include four input parameters in the form of the following bookings parameters:
•	booking id,
•	customer id,
•	booking date,
•	and table numberAddBooking. */
DELIMITER $$

CREATE PROCEDURE AddBooking (
    IN p_booking_id INT,
    IN p_customer_id VARCHAR(15),
    IN p_booking_date DATE,
    IN p_table_no INT
)
BEGIN
    INSERT INTO bookings (
        booking_id,
        booking_customer_id,
        booking_date,
        table_no
    )
    VALUES (
        p_booking_id,
        p_customer_id,
        p_booking_date,
        p_table_no
    );
END $$

DELIMITER ;

CALL AddValidBooking('booking_id', "customer_id", 'booking_date', 'table_no');

/*Task 31:
Create a new procedure called UpdateBooking that they can use to update existing bookings in the booking table.
The procedure should have two input parameters in the form of booking id and booking date. You must also include 
an UPDATE statement inside the procedure. */
DELIMITER $$

CREATE PROCEDURE UpdateBooking(
    IN in_booking_id INT,
    IN in_new_booking_date DATE
)
BEGIN
    UPDATE bookings
    SET booking_date = in_new_booking_date
    WHERE booking_id = in_booking_id;
END $$

DELIMITER ;
/*Task 32:
Create a new procedure called CancelBooking that they can use to cancel or remove a booking.
 The procedure should have one input parameter in the form of booking id. You must also write a 
 DELETE statement inside the procedure.*/

DELIMITER //

CREATE PROCEDURE CancelBooking (
    IN input_booking_id INT
)
BEGIN
    DELETE FROM bookings
    WHERE booking_id = input_booking_id;
END //

DELIMITER ;
