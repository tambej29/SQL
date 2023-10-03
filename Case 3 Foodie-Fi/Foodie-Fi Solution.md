<h1 align="center"> Case Study #3 - Foodie-Fi Solution </h1>

## A. Customer Journey
### Based off the 8 sample customers provided in the sample from the `subscriptions` table, write a brief description about each customer’s onboarding journey.

### Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
<details>
<summary>
View 8 sample customers:
</summary>
  
![image](https://github.com/tambej29/SQL/assets/68528130/2e66fed8-93e0-4ac4-bc0f-9fa00977f2d4)

</details>

```sql
SELECT
  customer_id,
  plan_name,
  DATE_FORMAT(start_date, '%M %d %Y') AS start_date
FROM plans AS p
JOIN subscriptions USING(plan_id)
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY customer_id, start_date;
```

| customer_id | plan_name     | start_date  |
|-------------|---------------|-------------|
| 1           | trial         | Aug 01 2020 |
| 1           | basic monthly | Aug 08 2020 |
| 2           | trial         | Sep 20 2020 |
| 2           | pro annual    | Sep 27 2020 |
| 11          | trial         | Nov 19 2020 |
| 11          | churn         | Nov 26 2020 |
| 13          | trial         | Dec 15 2020 |
| 13          | basic monthly | Dec 22 2020 |
| 13          | pro monthly   | Mar 29 2021 |
| 15          | trial         | Mar 17 2020 |
| 15          | pro monthly   | Mar 24 2020 |
| 15          | churn         | Apr 29 2020 |
| 16          | trial         | May 31 2020 |
| 16          | basic monthly | Jun 07 2020 |
| 16          | pro annual    | Oct 21 2020 |
| 18          | trial         | Jul 06 2020 |
| 18          | pro monthly   | Jul 13 2020 |
| 19          | trial         | Jun 22 2020 |
| 19          | pro monthly   | Jun 29 2020 |
| 19          | pro annual    | Aug 29 2020 |

- _Customer 1 initiated a free trial on August 1, 2020, and subscribed to the basic monthly plan after the trial expired._
- _Customer 2 initiated a free trial on September 20, 2020, and subscribed to the pro annual plan after the trial expired._
- _Customer 11 initiated a free trial on November 19, 2020, but did not convert to a paid customer after the trial ended._
- _Customer 13 initiated a free trial on December 15, 2020, and subscribed to the basic monthly plan after the trial expired. On March 29, 2021 they upgraded to the pro monthly plan._
- _Customer 15 initiated a free trial on March 17, 2020, and subscribed to the Pro Monthly plan after the trial expired. They canceled their subscription on April 29, 2020._
- _Customer 16 initiated a free trial on May 31, 2020, and subscribed to the basic monthly plan after the trial expired. On October 21, 2020 they upgraded to the pro annual plan._
- _Customer 18 initiated a free trial on July 06, 2020, and subscribed to the pro monthly plan after the trial expired._
- _Customer 19 initiated a free trial on June 22, 2020, and subscribed to the pro monthly plan after the trial expired. 2 months later, they upgraded to the pro annual plan._

---

## B. Data Analysis Questions
1. ### How many customers has Foodie-Fi ever had?
```sql
SELECT
  COUNT(DISTINCT customer_id) AS num_cust
FROM subscriptions;
```
| num_cust |
|----------|
| 1000     |

- _Foodie-Fi had 1000 customers_

2. ### What is the monthly distribution of `trial` plan `start_date` values for our dataset - use the start of the month as the group by value.
```sql
SELECT
  MONTHNAME(start_date) AS month,
  COUNT(customer_id) AS monthly_distribution
FROM subscriptions
WHERE plan_id = 0
GROUP  BY month
ORDER BY monthly_distribution DESC;
```
| month     | monthly_distribution |
|-----------|----------------------|
| March     | 94                   |
| July      | 89                   |
| August    | 88                   |
| January   | 88                   |
| May       | 88                   |
| September | 87                   |
| December  | 84                   |
| April     | 81                   |
| June      | 79                   |
| October   | 79                   |
| November  | 75                   |
| February  | 68                   |
- _March had the highest number of trials, while February had the lowest._

3. ### What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`.
```sql
SELECT
	plan_name,
  	COUNT(plan_id) AS event_count
FROM subscriptions
JOIN plans USING(plan_id)
WHERE EXTRACT(YEAR FROM start_date) > 2020
GROUP  BY plan_name;
```
| plan_name     | event_count |
|---------------|-------------|
| churn         | 71          |
| pro monthly   | 60          |
| pro annual    | 63          |
| basic monthly | 8           |
- _Most customers canceled their subscriptions after 2020._

4. ### What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
SELECT
	COUNT(DISTINCT customer_id) AS customer_count,
  	ROUND((SELECT COUNT(DISTINCT customer_id) * 100 FROM subscriptions WHERE plan_id = 4) /
  	COUNT(DISTINCT customer_id), 1) AS churn_rate
FROM subscriptions;
```
| customer_count | churn_rate |
|----------------|------------|
| 1000           | 30.7       |
- _Approximately 30% of Foodie-Fi customers have churned._

5. ### How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```sql
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
    ) as sbqry;
```
| customer_count | churn_count | churn_rate |
|----------------|-------------|------------|
| 1000           | 92          | 9          |
- _Approximately 9% of Foodie-Fi customers churned after their initial free trial._

6. ### What is the number and percentage of customer plans after their initial free trial?
```sql
SELECT
	plan_name,
	COUNT(customer_id) AS customer_count,
  	ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 2) AS plan_after_trial_percent
FROM	(
	SELECT
    	customer_id,
    	plan_name,
		ROW_NUMBER() OVER (PARTITION BY customer_id) as rn
	FROM subscriptions as s
  	JOIN plans as p using(plan_id)
	) AS t
WHERE t.rn = 2
GROUP BY plan_name;
```
| plan_name     | customer_count | plan_after_trial_percent |
|---------------|----------------|--------------------------|
| basic monthly | 546            | 54.60                    |
| pro annual    | 37             | 3.70                     |
| pro monthly   | 325            | 32.50                    |
| churn         | 92             | 9.20                     |
- _Approximately 55% of Foodie-Fi customers subscribed to the basic monthly plan after their initial trial._
- _Approximately 34% of Foodie-Fi customers subscribed to the pro monthly plan after their initial trial._
- _Approximately 4% of Foodie-Fi customers subscribed to the pro annual plan after their initial trial._
- _Approximately 9% of Foodie-Fi customers churned after their initial free trial._

7. ### What is the customer count and percentage breakdown of all 5 `plan_name` values at `2020-12-31`?
```sql
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
```
| plan_name     | customer_count | percentage |
|---------------|----------------|------------|
| basic monthly | 224            | 22.4       |
| pro annual    | 195            | 19.5       |
| churn         | 236            | 23.6       |
| pro monthly   | 326            | 32.6       |
| trial         | 19             | 1.9        |
- _By the end of 2020, the most popular subscription plan was Pro Monthly._
- _The customer churn rate increased from 9% after the trial period to 23.6% by the end of 2020._

8. ### How many customers have upgraded to an annual plan in 2020?
```sql
SELECT 
	COUNT(customer_id) AS num_cust
FROM subscriptions
WHERE DATE_FORMAT(start_date, '%Y') = 2020
AND plan_id = 3;
```
| num_cust |
|----------|
| 195      |
- _195 customers upgraded to an annual plan in 2020._

9. ### How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?
```sql
SELECT
	ROUND(AVG(DATEDIFF(b.start_date, a.start_date)), 1) AS avg_day
FROM subscriptions AS a
JOIN subscriptions AS b USING(customer_id)
WHERE b.plan_id= 3 AND a.plan_id = 0;
```
| avg_day |
|---------|
| 104.6   |
- _On average it takes approximately 105% days for a customer to upgrade to an annual plan from the day they joined Foodie-Fi._

10. ### Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```sql
SELECT
	time,
    	count(customer_id) as num_cust,
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
			 WHEN datediff(b.start_date, a.start_date) <= 360 THEN '1 year'
			 ELSE '1 + year' END AS time
	FROM subscriptions AS a
	JOIN subscriptions AS b USING(customer_id)
	WHERE b.plan_id= 3 AND a.plan_id = 0
    	)as t
GROUP BY 1
ORDER BY 2 DESC;
```
| time      | num_cust | avg_days |
|-----------|----------|----------|
| 1 month   | 49       | 10       |
| 5 months  | 42       | 133      |
| 6 months  | 36       | 162      |
| 4 months  | 35       | 101      |
| 3 months  | 34       | 71       |
| 7 months  | 26       | 191      |
| 2 months  | 24       | 42       |
| 9 months  | 5        | 257      |
| 8 months  | 4        | 224      |
| 1 year    | 1        | 346      |
| 10 months | 1        | 285      |
| 11 months | 1        | 327      |

On average, customers upgrade to an annual plan within:
- _10 days after the initial trial ending_
- _42 days after the initial trial ending (up to 2 months)_
- _71 days after the initial trial ending (up to 3 months)_
- _101 days after the initial trial ending (up to 4 months)_
- _133 days after the initial trial ending (up to 5 months)_
- _162 days after the initial trial ending (up to 6 months)_
- _191 days after the initial trial ending (up to 7 months)_
- _224 days after the initial trial ending (up to 8 months)_
- _257 days after the initial trial ending (up to 9 months)_
- _285 days after the initial trial ending (up to 10 months)_
- _327 days after the initial trial ending (up to 11 months)_
- _346 days after the initial trial ending (up to 1 year)_

11. ### How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql
SELECT
    COUNT(a.customer_id) AS downgraded_customers
FROM subscriptions AS a
JOIN subscriptions AS b ON a.customer_id = b.customer_id
    AND b.start_date < a.start_date
WHERE YEAR(a.start_date) = 2020
    AND YEAR(b.start_date) = 2020
    AND a.plan_id = 1 AND b.plan_id = 2;
```
| downgraded_customers |
|----------------------|
| 0                    |
- _No customer have downgraded from the pro monthly to the basic monthly plan._

---

### C. Challenge Payment Question
<details>
<summary>
View details:
</summary>
  
The Foodie-Fi team wants you to create a new `payments` table for the year 2020 that includes amounts paid by each customer in the `subscriptions` table with the following requirements:

  - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
  - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
  - upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
  - once a customer churns they will no longer make payments

Example outputs for this table might look like the following:
<p align="center">
<img src="https://github.com/tambej29/SQL/assets/68528130/783db9dd-f766-473b-a24d-1ea481d9fb5d">
</p>
</details>



