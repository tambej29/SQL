# Olist E-Commerce EDA
## Data Import:
```sql
-- 		Data Import			--
LOAD DATA LOCAL INFILE "file_path" -- This process will be repeated untill all the files are imported.
INTO TABLE table_name
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;
```
### There 8 datasets that will be used:
- Customers: This dataset has information about the customer and its location.
- Items: This dataset includes data about the items purchased within each order.
- Payments: This dataset includes data about the orders payment options.
- Orders: This is the core dataset. From each order you might find all other information.
- Reviews: This dataset includes data about the reviews made by the customers.
- Products: This dataset includes data about the products sold by Olist.
- Sellers: This dataset includes data about the sellers that fulfilled orders made at Olist.
- Product_cat_translation: Translates the product_category_name to english.

## Data Transformation:
### 1. Join all the datasets, rename some columns for readability, and leave unnecessary columns.
```sql
CREATE TABLE temp_t
SELECT
    c.customer_id, c.customer_unique_id, c.customer_zip_code_prefix as customer_zip_code, c.customer_city, c.customer_state,
    o.order_id, o.order_status, o.order_purchase_timestamp as order_date, o.order_delivered_customer_date as delivered_date, o.order_estimated_delivery_date as estimated_delivery_date,
    i.order_item_id, i.product_id, i.seller_id, i.shipping_limit_date, i.price, i.freight_value,
    pay.payment_sequential, pay.payment_type, pay.payment_installments, pay.payment_value,
    r.review_id, r.review_score,
    pct.product_category_name_english as product_name
FROM customers as c
JOIN orders as o on c.customer_id = o.customer_id
JOIN items as i on o.order_id = i.order_id
JOIN payments as pay on o.order_id = pay.order_id
JOIN reviews as r on r.order_id = o.order_id
JOIN products as p on i.product_id = p.product_id
JOIN product_cat_translation as pct on p.product_category_name = pct.ï»¿product_category_name;
-- Join the sellers table
CREATE TABLE olist_data as
SELECT
    t.*,
    s.seller_zip_code_prefix as seller_zip_code, s.seller_city, s.seller_state
FROM temp_t as t
JOIN sellers as s USING(seller_id);
```
### 2. Create a function to proper case customer_city and seller_city.
This function can be use to capitalize the first letter of every word withing a row, like the PROPER() function in Excel
```sql
DELIMITER //
CREATE FUNCTION proper(str VARCHAR(500))
RETURNS VARCHAR(500)
DETERMINISTIC
BEGIN
	DECLARE x, y, result VARCHAR(500);
    SET result = '';
    SET x = '';
    SET y = TRIM(LOWER(str));
    WHILE LENGTH(y) > 0 DO
    SET x = SUBSTRING_INDEX(y, ' ', 1);
      SET x = CONCAT(UPPER(SUBSTRING(x, 1,1)), SUBSTRING(x, 2));
      SET result = CONCAT(result, ' ', x);
      SET y = TRIM(SUBSTRING(y, LENGTH(x) + 1));
  END WHILE;
  RETURN TRIM(result);
END //
```
Check the newly created proper function functionality
```sql
SELECT
    customer_city, proper(customer_city) as proper_customer_city_name,
    seller_city, proper(seller_city) as proper_seller_city
FROM olist_data;
```
![Proper_check](https://github.com/tambej29/Analysis_Insights/blob/main/Olist%20E-commerce%20EDA/pic/Data_transformation/proper_check.png)

User the proper function to perform an update on customer city, and seller city columns.
```sql
SET sql_safe_updates = 0;
UPDATE olist_data
SET customer_city = proper(customer_city),
seller_city = proper(seller_city);
```
###3. Update the dataset columns to their proper data types.
Create a store procedure that will update date columns to date and alter the data types to date
```sql
/*
This procedure will first update the selected column to a date column, then will use the alter statement to change
the actual data type to datetime datatype
*/
DELIMITER //
CREATE PROCEDURE date_update(column_name TEXT)
BEGIN
    
    SET @query = -- first statement that will be prepared
    CONCAT(
    'UPDATE olist_data SET ',
        column_name, ' = ',
        'CASE '
        'WHEN ', column_name, ' LIKE ''%-%'' THEN STR_TO_DATE(', column_name, ', ''%Y-%m-%d %H:%i:%s'') ',
        'ELSE NULL END;'
          );
    PREPARE stmt FROM @query; -- preparing the statement
    EXECUTE stmt; -- excecuting the statement
    DEALLOCATE PREPARE stmt; -- deallocate the statement to free up resources
        
    SET @alter =  -- second statement
    CONCAT(
    'ALTER TABLE olist_data MODIFY ', column_name, ' DATETIME;'
          );
    PREPARE stmt FROM @alter; -- same steps as above ^^^
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
```
Update all the date columns by calling the procedure and passing in the column name. Without the procedure I would have to write the above query 4 times, one for each column.
```sql
CALL date_update('order_date');
CALL date_update('delivered_date');
CALL date_update('estimated_delivery_date');
CALL date_update('shipping_limit_date');
```
Check the dataset datatype (Image order: before update, after update)

![before](https://github.com/tambej29/Analysis_Insights/blob/main/Olist%20E-commerce%20EDA/pic/Data_transformation/describe.png) ![after](https://github.com/tambej29/Analysis_Insights/blob/main/Olist%20E-commerce%20EDA/pic/Data_transformation/describe_clean.png)

### 4. Aggregate the dataset
```sql
SELECT
     	customer_id, order_id, 
     	order_item_id,
     	product_id,
     	product_name,
	price, freight_value,
	payment_type, payment_value
FROM olist_data
ORDER BY customer_id;
```
![Duplicates](https://github.com/tambej29/Analysis_Insights/blob/main/Olist%20E-commerce%20EDA/pic/Data_transformation/duplicated.png)

Notice how customer '00331de1659c7f4fb660c8810e6de3f5' bought 3 of the same product? and the payment_value which is 243.69 is repeated 3 times? If I calculate the total sales, 
it would be wrong because there are many more duplicates. I will count the order_item_id which will be quantity and aggregate the data.
Create a new table with actual payment_value by using price, freight_value, and quantity.
Calcualte the time it took for items to be delivered and number of days the delivery was late by or early by
```sql
CREATE TABLE agg_data -- agg here is aggregated, since the data was aggregated
SELECT
	customer_id, customer_unique_id, customer_zip_code, customer_city, customer_state, order_id, order_status, order_date, 
    	delivered_date, estimated_delivery_date, DATEDIFF(delivered_date, order_date) as num_days_to_deliver, 
    	DATEDIFF(estimated_delivery_date, delivered_date) as delivered_on_time_or_not, quantity, product_id, product_name,
    	seller_id, shipping_limit_date, price, freight_value, payment_type,
    	ROUND(case when payment_type = 'voucher' then payment_value * quantity ELSE (price * quantity) +(freight_value * quantity) END, 2) as payment_value,
    	review_id, review_score, seller_city, seller_state, seller_zip_code
FROM(
SELECT
	customer_id, customer_unique_id, customer_zip_code, customer_city, customer_state, order_id, order_status, order_date, 
    	delivered_date, estimated_delivery_date, DATEDIFF(delivered_date, order_date) as num_days_to_deliver, 
    	DATEDIFF(estimated_delivery_date, delivered_date) as delivered_on_time_or_not, COUNT(order_item_id) as quantity, product_id, 
    	seller_id, shipping_limit_date, price, freight_value, payment_type, payment_value, review_id, review_score, product_name,  
    	seller_city, seller_state, seller_zip_code 
FROM olist_data
GROUP BY 
	customer_id, customer_unique_id, customer_zip_code, customer_city, customer_state, order_id, order_status, order_date, 
    	delivered_date, estimated_delivery_date, DATEDIFF(delivered_date, order_date), 
	DATEDIFF(estimated_delivery_date, delivered_date), product_id, 
    	seller_id, shipping_limit_date, price, freight_value, payment_type, payment_value, review_id, review_score, product_name,  
    	seller_city, seller_state, seller_zip_code
    	) as sbqry;
```
View the newly created data set
![agg_data](https://github.com/tambej29/Analysis_Insights/blob/main/Olist%20E-commerce%20EDA/pic/Data_transformation/olist_data.png)

Check the shape of the dataset
```sql
WITH shape as
	(
	SELECT
		ROW_NUMBER() OVER() as rn,
		COUNT(COLUMN_NAME) as num_of_columns
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = 'olist' AND TABLE_NAME = 'agg_data'
	),
row_cnt as
	(
	SELECT 
		ROW_NUMBER() over() as rn,
		COUNT(*) as num_of_rows
	FROM agg_data
    	)
SELECT
	num_of_rows, num_of_columns
FROM shape as s
JOIN row_cnt as r USING(rn);
```
![shape](https://github.com/tambej29/SQL/assets/68528130/5372b03f-dbb6-41e6-a74a-75c27da6179f)
## Data Analysis:

### Sales Analysis
What is the total sales?
```sql
-- Total sales
SELECT 
	ROUND(SUM(payment_value), 2)  AS total_sales
FROM agg_data
```

How many orders have been placed?
```sql
-- Total Orders
SELECT
	COUNT(DISTINCT order_id) AS total_orders
FROM agg_data;
```

Waht are the top and bottom 10 products by sales?
```sql
-- Top 10 products by sales
SELECT
	product_name,
    	ROUND(SUM(payment_value), 2) AS total_sales_by_product
FROM agg_data
GROUP BY product_name
ORDER BY total_sales_by_product DESC LIMIT 10;

--  Bottom 10 product by sales
SELECT
	product_name,
    	ROUND(SUM(payment_value), 2) AS total_sales_by_product
FROM agg_data
GROUP BY product_name
ORDER BY total_sales_by_product LIMIT 10;
```

What are the top and bottom 10 products by orders?
```sql
-- Top 10 product by orders
SELECT
	product_name,
    	COUNT(order_id) AS total_orders_by_product
FROM agg_data
GROUP BY product_name
ORDER BY total_orders_by_product DESC LIMIT 10;

-- bottom 10 product by orders
SELECT
	product_name,
    	COUNT(order_id) AS total_orders_by_product
FROM agg_data
GROUP BY product_name
ORDER BY total_orders_by_product ASC LIMIT 10;
```

Which cities are generating the most sales and orders?
```sql
-- Top 10 cities by orders
SELECT
	customer_city,
    	COUNT(order_id) AS orders_count
FROM agg_data
GROUP BY customer_city
ORDER BY orders_count DESC LIMIT 10;

-- Top 10 city by sales
SELECT
	customer_state,
    	ROUND(SUM(payment_value), 2)  AS total_sales
FROM agg_data
GROUP BY customer_state
ORDER BY total_sales DESC LIMIT 10;
```

What hours of the day do most orders occur?
```sql
SELECT
	HOUR(order_date) AS hr,
    	COUNT(order_id) AS total_order
FROM agg_data
GROUP BY hr
ORDER BY total_order DESC;
```

When are the most orders placed during the week?
```sql
SELECT
	DAYNAME(order_date) AS day,
    	COUNT(order_id) AS total_order
FROM agg_data
GROUP BY day
ORDER BY total_order DESC;
```

Montly order trend
```sql
SELECT
	MONTHNAME(order_date) AS month,
    	COUNT(order_id) AS total_order
FROM agg_data
GROUP BY month
ORDER BY total_order DESC;
```

### Shipping Insights
What is the average delivery time?
```sql
SELECT
	ROUND(AVG(num_days_to_deliver)) AS avg_delivering_days
FROM agg_data
WHERE num_days_to_deliver IS NOT NULL; -- if num_days_to_deliver is NULL then the order was not delivered;
```

What is the ratio between on time deliveries and late deliveries?
```sql
SELECT 
	CONCAT(ROUND(COUNT(CASE WHEN delivered_date <= estimated_delivery_date THEN order_id END) / COUNT(order_id) * 100), '%') AS `on_time_%`,
    	CONCAT(ROUND(COUNT(CASE WHEN delivered_date > estimated_delivery_date THEN order_id END) / COUNT(order_id) * 100), '%') AS `late_%`
FROM agg_data
WHERE order_status = 'delivered';
```
Percentage of delivered order vs not delivered
```sql
SELECT 
	CONCAT(ROUND(COUNT(CASE WHEN order_status = 'delivered' THEN order_id END) / COUNT(order_id) * 100, 2), '%') AS delivered,
	CONCAT(ROUND(COUNT(CASE WHEN order_status <> 'delivered' THEN order_id END) / COUNT(order_id) * 100, 2), '%') AS not_delivered
FROM agg_data;
```

### Customer insights
Waht is the average customer order quantity?
```sql
SELECT 
    ROUND(SUM(quantity) / COUNT(quantity), 1) AS avg_order
FROM agg_data;
```
What payment method do customers preffer to use?
```sql
SELECT
	payment_type,
    	CONCAT(ROUND(COUNT(payment_type) / (SELECT COUNT(*) FROM agg_data) * 100, 2), '%') as sdsfs
FROM agg_data
GROUP BY payment_type;
```
