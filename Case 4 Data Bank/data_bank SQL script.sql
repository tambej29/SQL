USE data_bank;

/*
-------------			Case Study #4 DATA BANK 			-------------
*/

/*
There is a new innovation in the financial industry called Neo-Banks: new aged digital only
banks without physical branches. 

Danny thought that there should be some sort of intersection between these new age banks, 
cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, 
they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money
they have in their accounts. There are a few interesting caveats that go with this business model, 
and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need 
some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their
data in a smart way to better forecast and plan for their future developments!
*/

-- 			---- Case Study Questions ----			--

-- A. Customer Nodes Exploration
/*
1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
*/

# 1. How many unique nodes are there on the Data Bank system?
SELECT
	COUNT(DISTINCT node_id) as unique_node_cnt
FROM customer_nodes;
-- They are 5 unique nodes in the Data Bank.

# 2. What is the number of nodes per region?
SELECT
	region_name,
    	COUNT(DISTINCT node_id) as unique_node,
    	COUNT(node_id) as node_cnt
FROM customer_nodes
JOIN regions USING(region_id)
GROUP BY 1;
-- Africas has 714 nodes, Europe has 616 nodes, Australia has 770 nodes, 
-- Ameria has 735 nodes, Asia has 665 nodes
-- Each region has 5 unique nodes.

# 3. How many customers are allocated to each region?
SELECT
	region_name,
    	COUNT(DISTINCT customer_id) as customer_cnt
FROM customer_nodes
JOIN regions USING(region_id)
GROUP BY 1
ORDER BY 2 DESC;
	
# 4. How many days on average are customers reallocated to a different node?
SELECT
	round(AVG(num_days)) as avg_days
FROM
	(SELECT
		customer_id,
		node_id,
		SUM(DATEDIFF(end_date, start_date)) as num_days
	FROM customer_nodes
	WHERE NOT DATE_FORMAT(end_date, '%Y') LIKE '9999%'
	GROUP BY 1,2
	ORDER BY 1,2
    ) as x;
-- On average customer spend 24 days on a node before being reallocted no another one.
select
	round(avg(datediff(end_date, start_date))) as avg_days
from customer_nodes
where NOT end_date like '9999%';
-- On average customer are reallocated to a different node every 15 days

# 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH cte AS
    (
    SELECT
        customer_id,
        region_name,
        DATEDIFF(end_date, start_date) AS num_days,
        ROW_NUMBER() OVER(PARTITION BY region_name ORDER BY DATEDIFF(end_date, start_date)) AS rn
    FROM customer_nodes
    JOIN regions USING(region_id)
    WHERE NOT end_date LIKE '%9999%'
    ),
max_rn AS
    (
    SELECT
        region_name,
        num_days,
        rn,
        MAX(rn) OVER(PARTITION BY region_name) AS max_rn
    FROM cte
    )
SELECT
    region_name,
    SUM(CASE WHEN rn = ROUND(max_rn * .50) THEN num_days END) AS median,
    SUM(CASE WHEN rn = ROUND(max_rn * .80) THEN num_days END) AS 80th_percentile,
    SUM(CASE WHEN rn = ROUND(max_rn * .95) THEN num_days END) AS 95th_percentile
FROM max_rn
GROUP BY region_name;

-- B.  Customer Transactions

/*
1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3.For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4.What is the closing balance for each customer at the end of the month?
5.What is the percentage of customers who increase their closing balance by more than 5%?
*/

# 1. What is the unique count and total amount for each transaction type?
SELECT
	txn_type,
	COUNT(txn_type) as unique_txn,
    	SUM(txn_amount) as total_amount
FROM customer_transactions
GROUP BY 1;

# 2. What is the average total historical deposit counts and amounts for all customers?
SELECT
    ROUND(AVG(txn_cnt)) AS avg_deposit_cnt,
    ROUND(AVG(avg_deposit),2) AS avg_amount
FROM
	(
	SELECT
		customer_id,
		COUNT(txn_type) AS txn_cnt,
		AVG(txn_amount) AS avg_deposit
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY 1
	ORDER BY customer_id
	) AS t;
-- The average deposit counts for all customer is 5, and the average deposit amount is 2718.34

# 3.For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
SELECT
	month,
    	COUNT(customer_id) as customer_cnt
FROM(
	SELECT
		customer_id,
		date_format(txn_date, '%b') as month,
		COUNT(CASE WHEN txn_type = 'deposit' THEN 1 END) as deposit_cnt,
		COUNT(CASE WHEN txn_type = 'purchase' THEN 1 END) as purchase_cnt,
		COUNT(CASE WHEN txn_type = 'withdrawal' THEN 1 END) as withdrawal_cnt
	FROM customer_transactions
	GROUP BY 1,2
	) as x
WHERE deposit_cnt > 1
	AND (purchase_cnt = 1 or withdrawal_cnt = 1)
GROUP BY month;

# 4.What is the closing balance for each customer at the end of the month?
WITH cte AS
    (
    SELECT
        customer_id,
        MONTH(txn_date) AS month_id,
        MONTHNAME(txn_date) AS month,
        SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
                ELSE - txn_amount
                END) AS total_amount
    FROM customer_transactions
    GROUP BY 1,2,3
    ORDER BY 1,2
    )
SELECT
    customer_id,
    month,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY month_id) closing_balance
FROM cte;

# 5.What is the percentage of customers who increase their closing balance by more than 5%?

WITH cte AS
    (
    SELECT
        customer_id,
        MONTH(txn_date) AS month_id,
        MONTHNAME(txn_date) AS month,
        SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
                ELSE - txn_amount
                END) AS total_amount
    FROM customer_transactions
    GROUP BY 1,2,3
    ORDER BY 1,2
    ),
closing AS
    (
    SELECT
        customer_id,
        month_id,
        month,
        SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY month_id) closing_balance
    FROM cte  
    ),
percent AS
    (
    SELECT
        *,
        ROUND((closing_balance - LAG(closing_balance) OVER(PARTITION BY customer_id)) /
        ABS(LAG(closing_balance) OVER(PARTITION BY customer_id)) * 100, 2) AS rate
    FROM closing
    )
SELECT
    ROUND(COUNT(DISTINCT customer_id) / 
    (SELECT COUNT(DISTINCT customer_id) FROM percent WHERE rate IS NOT NULL) * 100, 2) AS pct_custoemr
FROM percent
WHERE rate > 5;
-- 67 of the customers increased their closing balance by more 5%;

-- B.  Customer Transactions

/*To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time
*/

-- option 1
SELECT
	customer_id,
	txn_date,
	MONTHNAME(txn_date) AS month,
	txn_type,
	txn_amount,
	SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
		ELSE -txn_amount
		END) OVER (PARTITION BY customer_id, MONTHNAME(txn_date) ORDER BY txn_date) AS running_balance
FROM customer_transactions;

-- Option 2
WITH cte AS
	(
	SELECT
		customer_id,
		month(txn_date) AS month_id,
		MONTHNAME(txn_date) AS month,
		ROUND(SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
			ELSE -txn_amount
			END),2) avg_closing_balance
	FROM customer_transactions
	GROUP BY 1,2,3
	ORDER BY 1,2
	)
SELECT * FROM cte;

-- Option 3
SELECT
	customer_id,
	ROUND(AVG(running_balance)) AS avg_running_balance,
	MIN(running_balance) AS min_running_balance,
	MAX(running_balance) AS max_running_balance
FROM
	(
	SELECT
		customer_id,
		txn_date,
		MONTHNAME(txn_date) AS month,
		txn_type,
		txn_amount,
		SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
			ELSE -txn_amount
			END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
	FROM customer_transactions
	) AS t
GROUP BY customer_id;
	






