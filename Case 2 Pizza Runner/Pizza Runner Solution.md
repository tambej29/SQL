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

  - _The maximum # of pizzas delivered in one order is 3._





























---

## B. Runner and Customer Experience

---

## C. Ingredient Optimisation

---

## D. Pricing and Ratings
