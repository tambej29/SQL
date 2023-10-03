USE foodie_fi;

/*
			---- Case Study Questions ----			
*/

-- A. Customer Journey

-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible 

SELECT
	customer_id,
    	plan_name,
    	DATE_FORMAT(start_date, '%b %d %Y') AS start_date
FROM plans AS p
JOIN subscriptions USING(plan_id)
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY customer_id, DATE_FORMAT(start_date, '%Y-%m-%d');


-- B. Data Analysis Questions

/*
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
*/    

-- 1. How many customers has Foodie-Fi ever had?
SELECT
	COUNT(DISTINCT customer_id) AS num_cust
FROM subscriptions;
-- Foodie had 1000 customers.

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT
	MONTHNAME(start_date) AS month,
    	COUNT(customer_id) AS monthly_distribution
FROM subscriptions
WHERE plan_id = 0
GROUP  BY month
ORDER BY monthly_distribution DESC;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
	plan_name,
    	COUNT(plan_id) AS event_count
FROM subscriptions
JOIN plans USING(plan_id)
WHERE EXTRACT(YEAR FROM start_date) > 2020
GROUP  BY plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
	COUNT(DISTINCT customer_id) AS customer_count,
    	ROUND((SELECT COUNT(DISTINCT customer_id) * 100 FROM subscriptions WHERE plan_id = 4) /
   	COUNT(DISTINCT customer_id), 1) AS churn_rate
FROM subscriptions;
-- Out of 1000 customer, 30.7% have churned.

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT
    COUNT(DISTINCT customer_id) as customer_count,
    COUNT(churn) as churn_count,
    ROUND(COUNT(churn) * 100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) as churn_rate
FROM(
    SELECT
        customer_id,
        plan_name,
        CASE WHEN plan_name = 'trial' AND LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY plan_id) = 'churn' THEN 'churn'
        	ELSE NULL END as churn
    FROM subscriptions
    JOIN plans USING(plan_id)
    ) as sbqry
;

-- Out of 1000 customers, 9% have churn right after their trila ended.

-- 6. What is the number and percentage of customer plans after their initial free trial?
SELECT
	plan_name,
	COUNT(customer_id) AS customer_count,
    	ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 2) AS plan_after_trial_percent
FROM
	(SELECT
		customer_id,
        	plan_name,
		ROW_NUMBER() OVER (PARTITION BY customer_id) as rn
	FROM subscriptions as s
    	JOIN plans as p using(plan_id)
    	) AS t
WHERE t.rn = 2
GROUP BY plan_name;
-- After the trial, 54.6% chose basic monthly, 32.5% chose pro monthly, 9.2% canceled, and 3.7% chose pro annual

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH cte AS 
    (
    SELECT
        customer_id,
        plan_name,
        start_date,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date DESC) as last_plan
    FROM subscriptions
    JOIN plans USING(plan_id)
    WHERE YEAR(start_date) = 2020
    )
SELECT
    plan_name,
    COUNT(customer_id) AS customer_count,
    ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM cte) * 100, 1) as percentage
FROM cte
WHERE last_plan = 1
GROUP BY plan_name;

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT 
	COUNT(customer_id) AS num_cust
FROM subscriptions
WHERE DATE_FORMAT(start_date, '%Y') = 2020
AND plan_id = 3;
-- 195 customers upgraded to annual plan in 2020.

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
SELECT
	ROUND(AVG(DATEDIFF(b.start_date, a.start_date)), 1) AS avg_day
FROM subscriptions AS a
JOIN subscriptions AS b USING(customer_id)
WHERE b.plan_id= 3 AND a.plan_id = 0;
-- On average it takes a customer around 105 days to

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)    
SELECT
	MONTH,
    	COUNT(customer_id) AS num_cust,
	ROUND(AVG(DATEDIFF(annual_start, trial_start))) avg_days
FROM
	(SELECT
		a.customer_id,
		a.start_date AS trial_start,
		b.start_date AS annual_start,
		datediff(b.start_date, a.start_date) AS date_diff,
		CASE WHEN datediff(b.start_date, a.start_date) <= 30 THEN '1 month'
			 WHEN datediff(b.start_date, a.start_date) <= 60 THEN '2 months'
			 WHEN datediff(b.start_date, a.start_date) <= 90 THEN '3 months'
			 WHEN datediff(b.start_date, a.start_date) <= 120 THEN '4 months'
			 WHEN datediff(b.start_date, a.start_date) <= 150 THEN '5 months'
			 WHEN datediff(b.start_date, a.start_date) <= 180 THEN '6 months'
			 WHEN datediff(b.start_date, a.start_date) <= 210 THEN '7 months'
			 WHEN datediff(b.start_date, a.start_date) <= 240 THEN '8 months'
			 WHEN datediff(b.start_date, a.start_date) <= 270 THEN '9 months'
			 WHEN datediff(b.start_date, a.start_date) <= 300 THEN '10 months'
			 WHEN datediff(b.start_date, a.start_date) <= 330 THEN '11 months'
			 WHEN datediff(b.start_date, a.start_date) <= 360 THEN '12 months'
			 ELSE '1 + year' END AS month
	FROM subscriptions AS a
	JOIN subscriptions AS b USING(customer_id)
	WHERE b.plan_id= 3 AND a.plan_id = 0
    )as t
GROUP BY 1
ORDER BY 2 DESC;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT
    COUNT(a.customer_id) AS downgraded_customers
FROM subscriptions AS a
JOIN subscriptions AS b ON a.customer_id = b.customer_id
    AND b.start_date < a.start_date
WHERE YEAR(a.start_date) = 2020
    AND YEAR(b.start_date) = 2020
    AND a.plan_id = 1 AND b.plan_id = 2;
-- No one downgraded from pro monthly to a basic monthly plan in 2020


-- C. Challenge Payment Question

/*
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments
*/
DROP TABLE IF EXISTS 2020_payments;
CREATE TABLE 2020_payments as
WITH RECURSIVE cte AS
    (
    SELECT
        customer_id,
        plan_id,
        plan_name,
        start_date AS payment_date,
        IFNULL(LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), '2020-12-31') AS switch_date,
        PRICE AS amount,
        1 AS payment_order
    FROM subscriptions AS s
    JOIN plans AS p USING(plan_id)
    WHERE YEAR(start_date) = 2020
        AND s.plan_id NOT IN (0, 4)
UNION ALL
    SELECT
        customer_id,
        plan_id, 
        plan_name,
        DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
        switch_date,
        amount,
        payment_order + 1 AS payment_order
    FROM cte
    WHERE switch_date > DATE_ADD(payment_date, INTERVAL 1 MONTH)
        AND plan_id <> 3
    ),
new_price AS
    (
    SELECT
        *,
        LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY payment_date) AS last_plan,
        LAG(amount) OVER(PARTITION BY customer_id ORDER BY payment_date) AS last_amount
    FROM cte
    ORDER BY customer_id, payment_date
    )
SELECT
    customer_id,
    plan_id,
    plan_name,
    payment_date,
CASE 
    WHEN plan_id IN (2, 3) AND last_plan = 1 THEN amount - last_amount  
    ELSE amount 
END AS amount,
    payment_order
FROM new_price;
SELECT * FROM 2020_payments;
    






