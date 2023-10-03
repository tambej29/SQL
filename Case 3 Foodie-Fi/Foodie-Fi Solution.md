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
2. ### What is the monthly distribution of `trial` plan `start_date` values for our dataset - use the start of the month as the group by value.
3. ### What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`.
4. ### What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. ### How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. ### What is the number and percentage of customer plans after their initial free trial?
7. ### What is the customer count and percentage breakdown of all 5 `plan_name` values at `2020-12-31`?
8. ### How many customers have upgraded to an annual plan in 2020?
9. ### How many days on average does it take for a customer to upgrade from an annual plan from the day they join Foodie-Fi?
10. ### Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. ### How many customers downgraded from a pro monthly to a basic monthly plan in 2020?



