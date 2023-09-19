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
Check the function functionality
```sql
SELECT
    customer_city, proper(customer_city) as proper_customer_city_name,
    seller_city, proper(seller_city) as proper_seller_city
FROM olist_data;
```
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

