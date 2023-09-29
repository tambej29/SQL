# :pizza:Pizza Sales Analysis

### KPI

1. What is the total revenu?

```SQL
SELECT CONCAT('$', ROUND(SUM(quantity * price), 2)) as Revenu
FROM pizza_details;
```
	
| Revenu     |
|------------|
| $817860.05 |
 
2. How many pizzas have been sold?

```SQL
SELECT SUM(quantity) as Total_pizza_sold
FROM pizza_details;
```
| Total_pizza_sold |
|------------------|
| 49574            |
		 	
3. What is the total orders?

```SQL
SELECT COUNT(DISTINCT order_id) total_orders
FROM pizza_details;
```
| total_orders |
|--------------|
| 21350        |


4. What is the average order price?

```SQL
SELECT
	CONCAT('$', round(SUM(quantity * price) / COUNT(DISTINCT order_id), 2)) as Avg_order_value
FROM pizza_details;
```
| Avg_order_value |
|-----------------|
| $38.31          |

5. What is the average pizza(s) per order?

```SQL
SELECT
	round(SUM(quantity) / COUNT(DISTINCT order_id), 2) as avg_pizza_per_order
FROM order_details;
```
| avg_pizza_per_order |
|---------------------|
| 2.32                |

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
| category | revenu     | total_order | pizza_sold |
|----------|------------|-------------|------------|
| Classic  | $220053.1  | 10859       | 14888      |
| Supreme  | $208197    | 9085        | 11987      |
| Chicken  | $195919.5  | 8536        | 11050      |
| Veggie   | $193690.45 | 8941        | 11649      |

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
| size | revenu    | total_order |
|------|-----------|-------------|
| L    | 375318.7  | 12736       |
| M    | 249382.25 | 11159       |
| S    | 178076.5  | 10490       |
| XL   | 14076     | 544         |
| XXL  | 1006.6    | 28          |

_Large pizzas have generated the most sales._

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

| Time_range | time_category | total_order | Pizza_sold |
|------------|---------------|-------------|------------|
| 12-17      | Afternoon     | 9651        | 22692      |
| 17-20      | Evening       | 6050        | 13357      |
| 9-12       | Morning       | 3760        | 9526       |
| 20-23      | Night         | 1889        | 3999       |

```SQL
SELECT
	HOUR(time) as order_hour,
	COUNT(DISTINCT order_id) as Total_orders,
    	SUM(quantity) as Pizza_sold
FROM pizza_details
GROUP BY order_hour
ORDER BY order_hour;
```

| order_hour | Total_orders | Pizza_sold |
|------------|--------------|------------|
| 9          | 1            | 4          |
| 10         | 8            | 18         |
| 11         | 1231         | 2728       |
| 12         | 2520         | 6776       |
| 13         | 2455         | 6413       |
| 14         | 1472         | 3613       |
| 15         | 1468         | 3216       |
| 16         | 1920         | 4239       |
| 17         | 2336         | 5211       |
| 18         | 2399         | 5417       |
| 19         | 2009         | 4406       |
| 20         | 1642         | 3534       |
| 21         | 1198         | 2545       |
| 22         | 663          | 1386       |
| 23         | 28           | 68         |

_Customers are most likely to order pizza during lunch and early evening._

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
| Order_day | total_order | Pizza_sold |
|-----------|-------------|------------|
| Friday    | 3538        | 8242       |
| Thursday  | 3239        | 7478       |
| Saturday  | 3158        | 7493       |
| Wednesday | 3024        | 6946       |
| Tuesday   | 2973        | 6895       |
| Monday    | 2794        | 6485       |
| Sunday    | 2624        | 6035       |

_Most customers order pizza on Friday_

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

| order_year | Order_week | total_order | Pizza_sold |
|------------|------------|-------------|------------|
| 2015       | 1          | 254         | 591        |
| 2015       | 2          | 427         | 972        |
| 2015       | 3          | 400         | 917        |
| 2015       | 4          | 415         | 968        |
| 2015       | 5          | 436         | 975        |
| 2015       | 6          | 422         | 988        |
| 2015       | 7          | 423         | 976        |
| 2015       | 8          | 393         | 933        |
| 2015       | 9          | 409         | 972        |
| 2015       | 10         | 420         | 996        |
| 2015       | 11         | 404         | 965        |
| 2015       | 12         | 416         | 949        |
| 2015       | 13         | 427         | 954        |
| 2015       | 14         | 433         | 1025       |
| 2015       | 15         | 408         | 968        |
| 2015       | 16         | 414         | 967        |
| 2015       | 17         | 437         | 975        |
| 2015       | 18         | 423         | 934        |
| 2015       | 19         | 399         | 985        |
| 2015       | 20         | 458         | 1046       |
| 2015       | 21         | 414         | 953        |
| 2015       | 22         | 390         | 924        |
| 2015       | 23         | 423         | 997        |
| 2015       | 24         | 418         | 962        |
| 2015       | 25         | 410         | 920        |
| 2015       | 26         | 416         | 980        |
| 2015       | 27         | 474         | 1066       |
| 2015       | 28         | 417         | 950        |
| 2015       | 29         | 420         | 981        |
| 2015       | 30         | 433         | 985        |
| 2015       | 31         | 419         | 926        |
| 2015       | 32         | 426         | 955        |
| 2015       | 33         | 435         | 994        |
| 2015       | 34         | 407         | 959        |
| 2015       | 35         | 394         | 866        |
| 2015       | 36         | 397         | 945        |
| 2015       | 37         | 435         | 1009       |
| 2015       | 38         | 423         | 974        |
| 2015       | 39         | 288         | 674        |
| 2015       | 40         | 433         | 1008       |
| 2015       | 41         | 334         | 794        |
| 2015       | 42         | 386         | 933        |
| 2015       | 43         | 352         | 876        |
| 2015       | 44         | 371         | 810        |
| 2015       | 45         | 394         | 970        |
| 2015       | 46         | 400         | 944        |
| 2015       | 47         | 392         | 908        |
| 2015       | 48         | 491         | 1186       |
| 2015       | 49         | 424         | 1013       |
| 2015       | 50         | 417         | 959        |
| 2015       | 51         | 430         | 962        |
| 2015       | 52         | 298         | 693        |
| 2015       | 53         | 171         | 442        |

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
| Month     | Monthly_revenue |
|-----------|-----------------|
| July      | $72557.9        |
| May       | $71402.75       |
| March     | $70397.1        |
| November  | $70395.35       |
| January   | $69793.3        |
| April     | $68736.8        |
| August    | $68278.25       |
| June      | $68230.2        |
| February  | $65159.6        |
| December  | $64701.15       |
| September | $64180.05       |
| October   | $64027.6        |

_July is the most profitable month, while October is the least profitable month._

### Pizza Analysis

1. Which is the highest priced and lowest priced pizza?

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

| name                | price | Max_price | Min_price | Avg_price |
|---------------------|-------|-----------|-----------|-----------|
| The Greek Pizza     | 35.95 | 35.95     | 9.75      | 16.49     |
| The Pepperoni Pizza | 9.75  | 35.95     | 9.75      | 16.49     |

_The cheapes pizzas are price at $9.75 while the most expensive ones are priced at $35.95._

2. Which pizza is the most ordered?

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

| name               | size | Total_orders |
|--------------------|------|--------------|
| The Big Meat Pizza | S    | 1811         |

_The small Big Meat Pizza is the most orderd pizza_

2. Which pizza is the most ordered? Excluding size.
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
| name                     | Total_orders |
|--------------------------|--------------|
| The Classic Deluxe Pizza | 2416         |

_The Classic Deluxed is the most popular pizza among customers._

4. What is the sales percentage by category?

```sql
SELECT
	category,
    	CONCAT('$', ROUND(SUM(quantity * price), 2)) as Total_sales,
    	CONCAT(round(SUM(quantity * price) / (SELECT SUM(quantity * price) FROM pizza_details) * 100, 2), '%') as Percentage
FROM pizza_details
GROUP BY category
ORDER BY Total_sales DESC;
```
| category | Total_sales | Percentage |
|----------|-------------|------------|
| Classic  | $220053.1   | 26.91%     |
| Supreme  | $208197     | 25.46%     |
| Chicken  | $195919.5   | 23.96%     |
| Veggie   | $193690.45  | 23.68%     |

_Classic pizzas have generated the most sales._

5. What is the sales percentage by size?

```sql
SELECT
	size,
    	CONCAT('$', ROUND(SUM(quantity * price), 2)) as Total_sales,
    	CONCAT(round(SUM(quantity * price) / (SELECT SUM(quantity * price) FROM pizza_details) * 100, 2), '%') as Percentage
FROM pizza_details
GROUP BY size
ORDER BY Total_sales DESC;
```
| size | Total_sales | Percentage |
|------|-------------|------------|
| L    | $375318.7   | 45.89%     |
| M    | $249382.25  | 30.49%     |
| S    | $178076.5   | 21.77%     |
| XL   | $14076      | 1.72%      |
| XXL  | $1006.6     | 0.12%      |

_Large pizzas generated the most sales, while xx large has only contributed to 0.12% of total sales._

6. Top 5 sellers by revenue, quantity, and total orders
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
_Image order :point_up:: revenue, total quantity, total orders_

![](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/Queries%20pictures/Pizza%20analysis/top%205%20seller%20by%20revenue.png) ![](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/Queries%20pictures/Pizza%20analysis/top%205%20seller%20by%20quantity.png) ![](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/Queries%20pictures/Pizza%20analysis/top%205%20seller%20by%20orders.png)

_Although The Thai Chicken Pizza has generate more revenue, The Classic Deluxe Pizza is the best selling pizza._

7. Bottom 5 sellers by revenue, quantity, and total orders

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
_Image order: revenue :point_up:, total quantity, total orders_

![](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/Queries%20pictures/Pizza%20analysis/bottom%205%20sellers%20by%20revenue.png) ![](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/Queries%20pictures/Pizza%20analysis/bottom%205%20sellers%20by%20quantity.png) ![](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/Queries%20pictures/Pizza%20analysis/bottom%205%20sellers%20by%20orders.png)

_The Brie Carre Pizza is the overall worst selling pizza._

8. What are the most used ingredients?

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
| ingredient_name   | ingredient_count |
|-------------------|------------------|
| Garlic            | 27422            |
| Tomatoes          | 23694            |
| Red Onions        | 19547            |
| Red Peppers       | 16284            |
| Chicken           | 8443             |
| Mushrooms         | 8114             |
| Mozzarella Cheese | 6605             |
| Pepperoni         | 6542             |
| Green Olives      | 6174             |
| Artichokes        | 5682             |

_Garlic is and tomatoes are the most used ingredient._

## Summary:
- The majority of orders are placed during lunch and the evening hours, with the highest volume of orders occurring on Fridays.
- Classic pizzas are the most popular among customers, accounting for approximately 26% of total sales.
- Large pizzas contribute to approximately 45% of total sales
- The Thai Chicken Pizza generated the highest sales, but the Classic Deluxe Pizza is the overall best-selling pizza.
- The Brie Carre Pizza is the worst-performing pizza in both sales and orders.

Please Visit [Pizza dashboard](https://public.tableau.com/app/profile/jordan.t8456/viz/PizzaDashboard_16926530489230/Home) to see a visual representation, and [SQL Script](https://github.com/tambej29/SQL/blob/main/Pizza%20Analyst/pizza%20analyis%20script.sql) for the script.

✨Thank you ✨
