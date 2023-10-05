<h1 align="center"> Case Study #4 - Data Bank </h1>

## Table of Contents:
- [A. Customer Nodes Exploration](#a-customer-nodes-exploration)
- [B. Customer Transactions](#b-customer-transactions)
- [C. Data Allocation Challenge](#c-data-allocation-challenge)

## A. Customer Nodes Exploration

### 1. How many unique nodes are there on the Data Bank system?
```sql
SELECT
	COUNT(DISTINCT node_id) as unique_node_cnt
FROM customer_nodes;
```
| unique_node_cnt |
|-----------------|
| 5               |
- _They are 5unique nodes in the Data Bank system._

### 2. What is the number of nodes per region?
```sql
SELECT
	region_name,
    	COUNT(DISTINCT node_id) as unique_node,
    	COUNT(node_id) as node_cnt
FROM customer_nodes
JOIN regions USING(region_id)
GROUP BY 1;
```
| region_name | unique_node | node_cnt |
|-------------|-------------|----------|
| Africa      | 5           | 714      |
| America     | 5           | 735      |
| Asia        | 5           | 665      |
| Australia   | 5           | 770      |
| Europe      | 5           | 616      |
- _Australia has 770 nodes._
- _America has 735 nodes._
- _Africa has 714 nodes._
- _Asia has 665 nodes._
- _Europe has 616 nodes._ 

### 3. How many customers are allocated to each region?
```sql
SELECT
	region_name,
    	COUNT(DISTINCT customer_id) as customer_cnt
FROM customer_nodes
JOIN regions USING(region_id)
GROUP BY 1
ORDER BY 2 DESC;
```
| region_name | customer_cnt |
|-------------|--------------|
| Australia   | 110          |
| America     | 105          |
| Africa      | 102          |
| Asia        | 95           |
| Europe      | 88           |
- _Australia has 110 unique customers._
- _America has 105 unique customers._
- _Africa has 102 unique customers._
- _Asia has 95 unique customers._
- _Europe has 88 unique cusstomrs._ 
### 4. How many days on average are customers reallocated to a different node?
```sql
select
	round(avg(datediff(end_date, start_date))) as avg_days
from customer_nodes
where NOT end_date like '9999%';
```
| avg_days|
|---------|
| 15      |
- _On average, it takes 15 days to reallocate customers to a different node._

### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
```sql
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
```
| region_name | median | 80th_percentile | 95th_percentile |
|-------------|--------|-----------------|-----------------|
| Africa      | 15     | 24              | 28              |
| America     | 15     | 23              | 28              |
| Asia        | 15     | 23              | 28              |
| Australia   | 15     | 23              | 28              |
| Europe      | 15     | 24              | 28              |

- _The median day for customers to be reallocated to a new node is 15 days in all regions, with the 80th percentile at 24 days and the 95th percentile at 28 days, except for America, Australia and Asia, where the 80th percentile is 23 days._

## B. Customer Transactions

### 1. What is the unique count and total amount for each transaction type?
```sql
SELECT
	txn_type,
	COUNT(txn_type) as unique_txn,
	SUM(txn_amount) as total_amount
FROM customer_transactions
GROUP BY 1;
```
| txn_type   | unique_txn | total_amount |
|------------|------------|--------------|
| deposit    | 2671       | 1359168      |
| withdrawal | 1580       | 793003       |
| purchase   | 1617       | 806537       |

- _There have been 2,671 deposits totaling $1.36M, 1,580 withdrawals totaling $793K, and 2,671 purchases totaling $806.5K._

### 2. What is the average total historical deposit counts and amounts for all customers?
```sql
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
```
| avg_deposit_cnt | avg_amount |
|-----------------|------------|
| 5               | 508.61     |
- _The average deposit is $508.61, and there are 5 deposits on average._

### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```sql
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
```
| month | customer_cnt |
|-------|--------------|
| Jan   | 115          |
| Apr   | 50           |
| Feb   | 108          |
| Mar   | 113          |
- _The number of active customers decreased from 115 in January to 113 in February, 108 in March, and 50 in April._

### 4. What is the closing balance for each customer at the end of the month?
```sql
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
```
| customer_id | month    | closing_balance |
|-------------|----------|-----------------|
| 1           | January  | 312             |
| 1           | March    | -640            |
| 2           | January  | 549             |
| 2           | March    | 610             |
| 3           | January  | 144             |
| 3           | February | -821            |
| 3           | March    | -1222           |
| 3           | April    | -729            |
| 4           | January  | 848             |
| 4           | March    | 655             |
| 5           | January  | 954             |
| 5           | March    | -1923           |
| 5           | April    | -2413           |
| 6           | January  | 733             |
| 6           | February | -52             |
| 6           | March    | 340             |

- This is a semple of the result.

### 5. What is the percentage of customers who increase their closing balance by more than 5%?
```sql
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
```
| pct_customer|
|-------------|
| 67.40       |

## C. Data Allocation Challenge
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:
- Option 1: data is allocated based off the amount of money at the end of the previous month
- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
- Option 3: data is updated real-time

For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:
- running customer balance column that includes the impact each transaction
- customer balance at the end of each month
- minimum, average and maximum values of the running balance for each customer

Using all of the data available - how much data would have been required for each option on a monthly basis?
> [!Note]
>At this time I do not know how to calculate the data that would be required for each option on a monthly basis.

### Option 1
```sql
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
```
| customer_id | txn_date  | month    | txn_type   | txn_amount | running_balance |
|-------------|-----------|----------|------------|------------|-----------------|
| 1           | 1/2/2020  | January  | deposit    | 312        | 312             |
| 1           | 3/5/2020  | March    | purchase   | 612        | -612            |
| 1           | 3/17/2020 | March    | deposit    | 324        | -288            |
| 1           | 3/19/2020 | March    | purchase   | 664        | -952            |
| 2           | 1/3/2020  | January  | deposit    | 549        | 549             |
| 2           | 3/24/2020 | March    | deposit    | 61         | 61              |
| 3           | 4/12/2020 | April    | deposit    | 493        | 493             |
| 3           | 2/22/2020 | February | purchase   | 965        | -965            |
| 3           | 1/27/2020 | January  | deposit    | 144        | 144             |
| 3           | 3/5/2020  | March    | withdrawal | 213        | -213            |
| 3           | 3/19/2020 | March    | withdrawal | 188        | -401            |
| 4           | 1/7/2020  | January  | deposit    | 458        | 458             |
| 4           | 1/21/2020 | January  | deposit    | 390        | 848             |
| 4           | 3/25/2020 | March    | purchase   | 193        | -193            |
| 5           | 4/2/2020  | April    | withdrawal | 490        | -490            |
| 5           | 1/15/2020 | January  | deposit    | 974        | 974             |
| 5           | 1/25/2020 | January  | deposit    | 806        | 1780            |
| 5           | 1/31/2020 | January  | withdrawal | 826        | 954             |
| 5           | 3/2/2020  | March    | purchase   | 886        | -886            |
- This is a semple of the result.

### Option 2.
```sql
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
```
| customer_id | month_id | month    | avg_closing_balance |
|-------------|----------|----------|---------------------|
| 1           | 1        | January  | 312                 |
| 1           | 3        | March    | -952                |
| 2           | 1        | January  | 549                 |
| 2           | 3        | March    | 61                  |
| 3           | 1        | January  | 144                 |
| 3           | 2        | February | -965                |
| 3           | 3        | March    | -401                |
| 3           | 4        | April    | 493                 |
| 4           | 1        | January  | 848                 |
| 4           | 3        | March    | -193                |
| 5           | 1        | January  | 954                 |
| 5           | 3        | March    | -2877               |
| 5           | 4        | April    | -490                |
- This is a semple of the result.

### Option 3
```sql
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
```
| customer_id | avg_running_balance | min_running_balance | max_running_balance |
|-------------|---------------------|---------------------|---------------------|
| 1           | -151                | -640                | 312                 |
| 2           | 580                 | 549                 | 610                 |
| 3           | -732                | -1222               | 144                 |
| 4           | 654                 | 458                 | 848                 |
| 5           | -135                | -2413               | 1780                |
- This is a semple of the result.

---
✨Thank you for reading✨
