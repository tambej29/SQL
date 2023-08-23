# :pizza:Pizza Sales Analysis

## These are the questions that needs to be answered

```SQL
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
```

### KPI

1. What is the total revenu?

```SQL
SELECT CONCAT('$', ROUND(SUM(quantity * price), 2)) as Revenu
FROM pizza_details;
```

![tota_revenue](/Queries%20pictures/A-KPIS/total_revenue.png)

2. How many pizzas have been sold?

```SQL
SELECT SUM(quantity) as Total_pizza_sold
FROM pizza_details;
```

![pizza sold](/Queries%20pictures/A-KPIS/Total_pizza_sold.png)

3. What is the total orders?

```SQL
SELECT COUNT(DISTINCT order_id) total_orders
FROM pizza_details;
```

![tota_revenue](/Queries%20pictures/A-KPIS/Total_orders.png)

4. What is the average order price?

```SQL
SELECT
	CONCAT('$', round(SUM(quantity * price) / COUNT(DISTINCT order_id), 2)) as Avg_order_value
FROM pizza_details;
```

![](/Queries%20pictures/A-KPIS/Average_order_value.png)

5. What is the average pizza(s) per order?

```SQL
SELECT
	round(SUM(quantity) / COUNT(DISTINCT order_id), 2) as avg_pizza_per_order
FROM order_details;
```
![](/Queries%20pictures/A-KPIS/Avg_pizza_per_order.png)

### Pizza Category and Size

1. What is the total revenue and the # of orders per category?

```SQL
SELECT 
	category,
	CONCAT('$', round(SUM(quantity * price), 2)) as revenu,
    COUNT(DISTINCT order_id) as total_order,
    SUM(quantity) as pizza_sold
FROM pizza_details
GROUP BY category
ORDER BY 2 DESC;
```
![](/Queries%20pictures/Sector%20Analyst/category.png)

_Classic pizzas have yielded the most revenue_

2. What is the total revenue and the # of orders per size?

```SQL
SELECT 
	size,
	round(SUM(quantity * price), 2) as revenu,				
    COUNT(DISTINCT order_id) as total_order,
    concat(round(COUNT(DISTINCT order_id) / (SELECT count(DISTINCT order_id) FROM order_details) * 100, 2), '%') as percantage
FROM pizza_details
GROUP BY size
ORDER BY 2 DESC;
```
![](/Queries%20pictures/Sector%20Analyst/size.png)

_Large pizza have yielded the most revenue_

### Trend Analysis

1. What is the peak time for orders?

```SQL
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
```
![](/Queries%20pictures/Seasonal%20Analysis/time_range%20trend.png)
```SQL
SELECT
	HOUR(time) as order_hour,
    COUNT(DISTINCT order_id) as Total_orders,
    SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY order_hour
ORDER BY order_hour;
```
![](/Queries%20pictures/Seasonal%20Analysis/hourly_trend%20for%20pizza_sold.png)

_Peak orders are during lunch and in the early evening_

2. What day of the week has the highest volume of orders?

```sql
SELECT
	DAYNAME(date) as Order_day,
    COUNT(DISTINCT order_id) as total_order,
    SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY Order_day
ORDER BY total_order DESC;
```
![](/Queries%20pictures/Seasonal%20Analysis/Weekday%20orders.png)

_Most customers order pizza on Fiday_

3. What is weekly trend for total orders?

```sql
SELECT
	DAYNAME(date) as Order_day,
    COUNT(DISTINCT order_id) as total_order,
    SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY Order_day
ORDER BY total_order DESC;
```
![](/Queries%20pictures/Seasonal%20Analysis/Week_trend%201.png) ![](/Queries%20pictures/Seasonal%20Analysis/Week_trend%202.png)

_The 48Th week which is late november is the best performing week_

4. What is the montly revenue trend?

```sql
SELECT
	MONTHNAME(date) as Month,
	CONCAT('$', round(SUM(quantity * price), 2)) as Monthly_revenue
FROM pizza_details
GROUP BY month
ORDER BY Monthly_revenue DESC;
```
![](/Queries%20pictures/Seasonal%20Analysis/monthly_trend.png)

_July is the best performing month, while October is the worst one._

### Pizza Analysis

1. Which is the highest and lowest selling pizza?

```sql
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
```
![](/Queries%20pictures/Pizza%20analysis/highes_lowest%20price%20pizza.png)

_The cheapes pizzas are price at $9.75 while the most expensive ones are priced at $35.95._

2. What is the most ordered pizza?

```sql
-- with size
SELECT 
	name,
    size,
    COUNT(order_id) as Total_orders
FROM pizza_details
GROUP BY name, size
ORDER BY total_orders DESC
LIMIT 1;
```
![](/Queries%20pictures/Pizza%20analysis/Most_orderd_pizza.png)

_The small Big Meat Pizza is the most orderd pizza_
```sql
-- Without size
SELECT 
	name,
    COUNT(order_id) as Total_orders
FROM pizza_details
GROUP BY name
ORDER BY total_orders DESC
LIMIT 1;
```
![](/Queries%20pictures/Pizza%20analysis/Most_orderd_pizza_no_size.png)

_The Classic Deluxed is the all time favorite pizza._


3. What is the sales percentage by category?

```sql
SELECT
	category,
    CONCAT('$', ROUND(SUM(quantity * price), 2)) as Total_sales,
    CONCAT(round(SUM(quantity * price) / (SELECT SUM(quantity * price) FROM pizza_details) * 100, 2), '%') as Percentage
FROM pizza_details
GROUP BY category
ORDER BY Total_sales DESC;
```
![](/Queries%20pictures/Pizza%20analysis/percent%20of%20sales%20by%20category.png)

_Classic pizzas are the all time faborite by customers._

4. What is the sales percentage by size?

```sql
SELECT
	size,
    CONCAT('$', ROUND(SUM(quantity * price), 2)) as Total_sales,
    CONCAT(round(SUM(quantity * price) / (SELECT SUM(quantity * price) FROM pizza_details) * 100, 2), '%') as Percentage
FROM pizza_details
GROUP BY size
ORDER BY Total_sales DESC;
```
![](/Queries%20pictures/Pizza%20analysis/percent%20of%20sales%20by%20size.png)

_Large pizzas generated the most sales, while xx large has only contributed to 0.12 percent of sales._

5. Top 5 sellers by revenue, quantity, and total orders
```sql
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
```
_Image order: revenue, total quantity, total orders_

![](/Queries%20pictures/Pizza%20analysis/top%205%20seller%20by%20revenue.png) ![](/Queries%20pictures/Pizza%20analysis/top%205%20seller%20by%20quantity.png) ![](/Queries%20pictures/Pizza%20analysis/top%205%20seller%20by%20orders.png)

_Although The Thai Chicken Pizza has generate more revenue, The Classic Deluxe Pizza is the best selling pizza._

6. Bottom 5 sellers by revenue, quantity, and total orders

```sql
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
```
_Image order: revenue, total quantity, total orders_

![](/Queries%20pictures/Pizza%20analysis/bottom%205%20sellers%20by%20revenue.png) ![](/Queries%20pictures/Pizza%20analysis/bottom%205%20sellers%20by%20quantity.png) ![](/Queries%20pictures/Pizza%20analysis/bottom%205%20sellers%20by%20orders.png)

_The Brie Carre Pizza is the overall worst selling pizza._

7. What are the most used ingredients?

```sql
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
```
![](/Queries%20pictures/Pizza%20analysis/Ingredient%20count.png)

_Garlic is the overall most used ingredient, followed by tomatoes._