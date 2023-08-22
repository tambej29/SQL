USE pizza_sales;

SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM pizza_types;
SELECT * FROM pizzas;

-- Change the date, and time columns data type from orders tabel to the appropriate data type.    
ALTER TABLE orders
MODIFY COLUMN date DATE,
MODIFY COLUMN time TIME;

-- Crate a pizza_details view by joining all the tables.
 CREATE VIEW pizza_details as 
 SELECT   
	order_detail,     
	od.order_id,     
    p.pizza_id,     
    quantity,     
    date,     
    time,     
    category,     
    size,     
    name,     
    price,     
    ingredients 
FROM order_details as od 
JOIN orders as o on o.order_id = od.order_id 
JOIN pizzas as p on p.pizza_id = od.pizza_id
JOIN pizza_types as pt on pt.pizza_type_id = p.pizza_type_id;
    
-- Here are the insights that need to be retrieved from our dataset.
/*
KPI
1. Total Revenue
2. Total Pizza Sold
3. Total Orders
4. Average Order Value
5. Avg Pizzas Per Order

-----------------------------------------------------------------------------------------------------
SECTOR ANALYSIS
1. What is the revenue of pizza across different categories?
2. What is the revenue of pizza accross different size?

-----------------------------------------------------------------------------------------------------
SEASONAL ANALYSIS
1. Which days of the week have the highest number of orders?
2. At what time do most orders occur?
3. What's the weekly trend?
3. Which month has the highest revenue?

-----------------------------------------------------------------------------------------------------

PIZZA ANALYSIS
1. Which is the highest and cheapest pizza price?
2. Which pizza is the favorite of customers (most order pizza)?
3. Percentage of sales by pizza category
4. Percentage of sales by pizza size
5. Top 5 Best sellers
6. Bottom 5 worst sellers
Which ingredients does the restaurant need to make sure they have on hand to make the ordered pizzas?
-----------------------------------------------------------------------------------------------------
*/


#		KPI

-- 1. Total Revenu
SELECT CONCAT('$', ROUND(SUM(quantity * price), 2)) as Revenu
FROM pizza_details;

-- 2. Total Pizza Sold
SELECT SUM(quantity) as Total_pizza_sold
FROM pizza_details;

-- 3. Total Orders
SELECT COUNT(DISTINCT order_id) total_orders
FROM pizza_details;

-- 4. Average Order Value
SELECT
	CONCAT('$', round(SUM(quantity * price) / COUNT(DISTINCT order_id), 2)) as Avg_order_value
FROM pizza_details;

-- 5 Average Pizzas Per Order
SELECT
	round(SUM(quantity) / COUNT(DISTINCT order_id), 2) as avg_pizza_per_order
FROM order_details;


#		SECTOR ANALYSIS

-- 1. Total revenue and number of order per category
SELECT 
	category,
	CONCAT('$', round(SUM(quantity * price), 2)) as revenu,
    COUNT(DISTINCT order_id) as total_order,
    SUM(quantity) as pizza_sold
FROM pizza_details
GROUP BY category
ORDER BY 2 DESC;

-- 2. Total revenue and number of order per size
SELECT 
	size,
	round(SUM(quantity * price), 2) as revenu,				
    COUNT(DISTINCT order_id) as total_order,
    concat(round(COUNT(DISTINCT order_id) / (SELECT count(DISTINCT order_id) FROM order_details) * 100, 2), '%') as percantage
FROM pizza_details
GROUP BY size
ORDER BY 2 DESC;


#		SEASONAL ANALYSIS

-- 1. Time range  trend of total orders and amount sold
SELECT
	CASE
		WHEN HOUR(time) BETWEEN 9 AND 12 THEN '9-12'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN '12-17'
        WHEN HOUR(time) BETWEEN 17 AND 20 THEN '17-20'
        WHEN HOUR(time) BETWEEN 20 AND 23 THEN '20-23'
        End as Time_range,
	CASE
		WHEN HOUR(time) BETWEEN 9 AND 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 17 AND 20 THEN 'Evening'
        WHEN HOUR(time) BETWEEN 20 AND 23 THEN 'Night'
        ELSE 'Other' END as time_category,
        COUNT(DISTINCT order_id) as total_order,
        SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY Time_range, time_category
ORDER BY total_order DESC;

-- Hourly trend for total orders, and amount sold
SELECT
	HOUR(time) as order_hour,
    COUNT(DISTINCT order_id) as Total_orders,
    SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY order_hour
ORDER BY order_hour;

-- 2. Weekday trend for total orders, and amount sold
SELECT
	DAYNAME(date) as Order_day,
    COUNT(DISTINCT order_id) as total_order,
    SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY Order_day
ORDER BY total_order DESC;

-- 3. Weekly trend for total orders, and amount sold
SELECT
	YEAR(date) as order_year,
	WEEKOFYEAR(date) as Order_week,
    COUNT(DISTINCT order_id) as total_order,
    SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY Order_year, Order_week
ORDER BY Order_week;

-- 4. Monthly revenue trend
SELECT
	MONTHNAME(date) as Month,
	CONCAT('$', round(SUM(quantity * price), 2)) as Monthly_revenue
FROM pizza_details
GROUP BY month
ORDER BY Monthly_revenue DESC;


#		PIZZA ANALYSIS	

-- 1. Which is the highest and Lowest pizza price?
SELECT DISTINCT *
FROM
(SELECT
	name,
    price,
    MAX(price) OVER() as Max_price,
    MIN(price) OVER() as Min_price,
	round(AVG(price) OVER(), 2) as Avg_price
FROM pizza_details
ORDER BY price DESC) as a
WHERE price in (a.max_price, a.min_price);

-- 2. Which pizza is the favorite of customers (most order pizza)?
SELECT 
	name,
    size,
    COUNT(order_id) as Total_orders
FROM pizza_details
GROUP BY name, size
ORDER BY total_orders DESC
LIMIT 1;

-- Without size
SELECT 
	name,
    COUNT(order_id) as Total_orders
FROM pizza_details
GROUP BY name
ORDER BY total_orders DESC
LIMIT 1;

-- 3. Percentage of sales by pizza category
SELECT
	category,
    CONCAT('$', ROUND(SUM(quantity * price), 2)) as Total_sales,
    CONCAT(round(SUM(quantity * price) / (SELECT SUM(quantity * price) FROM pizza_details) * 100, 2), '%') as Percentage
FROM pizza_details
GROUP BY category
ORDER BY Total_sales DESC;

-- 4. Percentage of sales by pizza size
SELECT
	size,
    CONCAT('$', ROUND(SUM(quantity * price), 2)) as Total_sales,
    CONCAT(round(SUM(quantity * price) / (SELECT SUM(quantity * price) FROM pizza_details) * 100, 2), '%') as Percentage
FROM pizza_details
GROUP BY size
ORDER BY Total_sales DESC;
    
-- Top 5 Best sellers by Revenue
SELECT
	name, 
    round(SUM(quantity * price), 2) as Revenu
FROM pizza_details
GROUP BY name
ORDER BY Revenu DESC LIMIT 5;

-- Top 5 Best sellers total quantity
SELECT
	name, 
    SUM(quantity) as Total_sold
FROM pizza_details
GROUP BY name
ORDER BY Total_sold DESC LIMIT 5;

-- Top 5 Best sellers total_orders
SELECT
	name, 
    COUNT(DISTINCT order_id) Total_orders
FROM pizza_details
GROUP BY name
ORDER BY Total_orders DESC LIMIT 5;


-- Top 5 bottom sellers by Revenue
SELECT
	name, 
    round(SUM(quantity * price), 2) as Revenu
FROM pizza_details
GROUP BY name
ORDER BY Revenu ASC LIMIT 5;

-- Top 5 bottom sellers total quantity
SELECT
	name, 
    SUM(quantity) as Total_sold
FROM pizza_details
GROUP BY name
ORDER BY Total_sold ASC LIMIT 5;

-- Top 5 bottom sellers total_orders
SELECT
	name, 
    COUNT(DISTINCT order_id) as Total_orders
FROM pizza_details
GROUP BY name
ORDER BY Total_orders ASC LIMIT 5;

-- Top used ingredients
WITH RECURSIVE num as
	(
    SELECT 1 as n
UNION ALL
	SELECT n + 1 FROM num
    WHERE n < 10
    ),
ingredient as
	(
    SELECT
		name,
        size,
        n as ingredient_id,
		substring_index(substring_index(ingredients, ',', n), ',',-1) as ingredient_name
	FROM num
    JOIN pizza_details as pd
		on n <= length(ingredients) - length(replace(ingredients, ',', '')) + 1
    )
SELECT
	ingredient_name,
	COUNT(ingredient_name) as ingredient_count
FROM ingredient
GROUP BY ingredient_name
ORDER BY ingredient_count DESC
LIMIT 10;
