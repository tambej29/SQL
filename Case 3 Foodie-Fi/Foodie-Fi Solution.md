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
```
| plan_name     | customer_count | plan_after_trial_percent |
|---------------|----------------|--------------------------|
| basic monthly | 546            | 54.60                    |
| pro annual    | 37             | 3.70                     |
| pro monthly   | 325            | 32.50                    |
| churn         | 92             | 9.20                     |
- _Approximately 55% of Foodie-Fi customers subscribed to the basic monthly plan after their initial trial._
- _Approximately 4% of Foodie-Fi customers subscribed to the pro annual plan after their initial trial._
- _Approximately 34% of Foodie-Fi customers subscribed to the pro monthly plan after their initial trial._
- _Approximately 9% of Foodie-Fi customers churned after their initial free trial._
8. ### What is the customer count and percentage breakdown of all 5 `plan_name` values at `2020-12-31`?
9. ### How many customers have upgraded to an annual plan in 2020?
10. ### How many days on average does it take for a customer to upgrade from an annual plan from the day they join Foodie-Fi?
11. ### Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
12. ### How many customers downgraded from a pro monthly to a basic monthly plan in 2020?



