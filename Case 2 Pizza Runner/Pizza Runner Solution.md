<h1 align="center"> Case Study #2 - Pizza Runner Solution </h1>

## Table of Contents:
  - [A. Pizza metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
  - [C. Ingredient Optimisation](#c-ingredient-optimisation)
  - [D. Pricing and Ratings](#d-pricing-and-ratings)

---

## A. Pizza Metrics

1. ### How many pizzas were ordered?
```sql
select
	count(pizza_id) as pizza_ordered
from customer_orders;
```
| pizza_ordered |
|---------------|
| 14            |

  - _14 pizzas were ordered._

2.  ### How many unique customer orders were made?
```sql
select
	count(distinct order_id) as unique_customer_orders
from customer_orders;
```
| unique_customer_orders |
|------------------------|
| 10                     |

  - _10 uniques customer orders were made._

3. ### How many successful orders were delivered by each runner?
```sql
select
	runner_id,
  	count(order_id) as delivered_orders
from runner_orders
where pickup_time is not null
group by 1;
```
| runner_id | delivered_orders |
|-----------|------------------|
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

  - _Runner 1 made 4 successful deliveries._
  - _Runner 2 made 3 successful deliveries._
  - _Runner 3 made 1 successful deliveries._

4. ### How many of each type of pizza was delivered?
```sql
select
	pa.pizza_name,
  	count(co.pizza_id) pizza_delivered
from runner_orders as ro
join customer_orders as co
	using(order_id)
join pizza_names as pa
	on co.pizza_id = pa.pizza_id
where ro.pickup_time is not null
group by 1;
```
| pizza_name | pizza_delivered |
|------------|-----------------|
| Meatlovers | 9               |
| Vegetarian | 3               |

  - _9 Meatlovers pizzas delivered_
  - _3 Vegetarian pizzas delivered_

5. ### How many Vegetarian and Meatlovers were ordered by each customer?
```sql
select
	customer_id,
  	count(case when pizza_name = 'meatlovers' then pizza_id end) as meatlovers_cnt,
  	count(case when pizza_name = 'vegetarian' then pizza_id end) as vegetarian_cnt
from customer_orders as co
join pizza_names as pn using(pizza_id)
group by 1;
```
| customer_id | meatlovers_cnt | vegetarian_cnt |
|-------------|----------------|----------------|
| 101         | 2              | 1              |
| 102         | 2              | 1              |
| 103         | 3              | 1              |
| 104         | 3              | 0              |
| 105         | 0              | 1              |

  - _101 ordered 2 Meatlovers, and 1 Vegetarian pizzas._
  - _102 ordered 2 Meatlovers, and 1 Vegetarian pizzas._
  - _103 ordered 3 Meatlovers, and 1 Vegetarian pizzas._
  - _104 ordered 3 Meatlovers, and 0 Vegetarian pizzas._
  - _105 ordered 0 Meatlovers, and 1 Vegetarian pizzas._

6. ### What was the maximum number of pizzas delivered in a single order?
```sql
select
	ro.order_id,
	count(co.pizza_id) as delivered_pizza
from runner_orders as ro
join customer_orders as co
	using(order_id)
where ro.pickup_time is not null
group  by 1
order by 2 desc limit 1;
```
| order_id | delivered_pizza |
|----------|-----------------|
| 4        | 3               |

  - _The maximum # of pizzas delivered in one order was 3._

7. ### For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
select
	co.customer_id,
sum(case
	when (exclusions is not null and length(exclusions) >0)
	or (extras is not null and length(extras) >0) Then 1
	else 0
	end) as changes,
sum(case
	when (exclusions is not null and length(exclusions) >0)
	or (extras is not null and length(extras) >0) Then 0
	else 1
	end) as no_changes
from customer_orders as co
join runner_orders as ro
	using (order_id)
where pickup_time is not null
group by 1;
```
| customer_id | changes | no_changes |
|-------------|---------|------------|
| 101         | 0       | 2          |
| 102         | 0       | 3          |
| 103         | 3       | 0          |
| 104         | 2       | 1          |
| 105         | 1       | 0          |

- _101 had 2 delivered pizzas with no changes made._
- _102 had 3 delivered pizzas with no changes made._
- _103 had 3 delivered pizzas, and made changes to all 3 pizzas._
- _104 had 3 delivered pizzas, and made changes to 2 pizzas._
- _105 has 1 pizza delivered with no chagnes made._

8. ### How many pizzas were delivered that had both exclusions and extras?
```sql
select
	count(co.pizza_id) as `Pizzas delivered with exclusions & extras`
from customer_orders as co
join runner_orders as ro using (order_id)
join pizza_names as pa using (pizza_id)
where pickup_time is not null
and case
	when (exclusions is not null and length(exclusions) >0)
	and (extras is not null and length(extras) >0) Then 1
	else 0
	end;
```
| Pizzas delivered with exclusions & extras |
|-------------------------------------------|
| 1                                         |

- _Only 1 pizza was delivered that had both exclusions, and extras._

9. ### What was the total volume of pizzas ordered for each hour of the day?
```sql
select
	extract(hour from order_time) as hour,
	count(pizza_id) as pizza_ordered
from customer_orders
group by 1
order by 2 desc;
```
| hour | pizza_ordered |
|------|---------------|
| 18   | 3             |
| 23   | 3             |
| 13   | 3             |
| 21   | 3             |
| 19   | 1             |
| 11   | 1             |

- _3 pizzas were ordered at the 18th hour of the day._
- _3 pizzas were ordered at the 23th hour of the day._
- _3 pizzas were ordered at the 13th hour of the day._
- _3 pizzas were ordered at the 21th hour of the day._
- _1 pizzas were ordered at the 19th hour of the day._
- _1 pizzas were ordered at the 11th hour of the day._

10. ### What was the volume of orders for each day of the week?
```sql
select
	dayname(order_time) as day,
	count(order_id) as pizza_ordered
from customer_orders
group by 1
order by 2 desc;
```
| day       | pizza_ordered |
|-----------|---------------|
| Wednesday | 5             |
| Saturday  | 5             |
| Thursday  | 3             |
| Friday    | 1             |

- _5 orders made on Wednesday._
- _5 orders made on Saturday._
- _3 orders made on Thursday._
- _1 order made on Friday._

---

## B. Runner and Customer Experience

































---

## C. Ingredient Optimisation

---

## D. Pricing and Ratings
