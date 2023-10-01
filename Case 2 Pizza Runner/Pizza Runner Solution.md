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

1. ### How many runners signed up for each 1 week period? (i.e. week starts `2021-01-01`)
```sql
select
	extract(week from registration_date + 3) as week,
    	count(runner_id) as runner_cnt
from runners
group by 1;
```
| week | runner_cnt |
|------|------------|
| 1    | 2          |
| 2    | 1          |
| 3    | 1          |

- _2 runners signed up on the first week of 2021._
- _1 runner signed up on the second and third week of 2021._

2. ### What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
select
	runner_id,
    	round(time_format(avg(timediff(pickup_time, order_time)), '%i.%s')) as avg_time
from runner_orders 
join customer_orders using (order_id)
where pickup_time is not null
group by 1;
```
| runner_id | avg_time |
|-----------|----------|
| 1         | 16       |
| 2         | 24       |
| 3         | 10       |

- _Runner 1 average delivery time is about 16 minutes._
- _Runner 2 average delivery time is about 24 minutes._
- _Runner 3 average delivery time is about 10 minutees._

3. ### Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
select
	pizza_cnt,
    	round(avg(time_diff)) as avg_prep_time
from(
	select
		count(pizza_id) as pizza_cnt,
		time_format(timediff(pickup_time, order_time), '%i.%s') as time_diff
	from runner_orders as rn
	join customer_orders as co using(order_id)
	where pickup_time is not null
	group by 2
    ) as sbqry
group by pizza_cnt;
```
| pizza_cnt | avg_prep_time |
|-----------|---------------|
| 1         | 12            |
| 2         | 18            |
| 3         | 29            |

- _Preparation time increases with the number of pizzas ordered._

4. ### What was the average distance travelled for each customer?
```sql
select
	customer_id,
    	concat(round(avg(distance)), ' km') as avg_distance
from runner_orders
join customer_orders using(order_id)
group by 1;
```
| customer_id | avg_distance |
|-------------|--------------|
| 101         | 20 km        |
| 102         | 17 km        |
| 103         | 23 km        |
| 104         | 10 km        |
| 105         | 25 km        |

- _The average distance traveled for customer 101 was 20 km_
- _17 km for customer 102_
- _23 km for customer 103_
- _10 km for customer 104_
- _25 km for customer 105_

5. ### What was the difference between the longest and shortest delivery times for all orders?
```sql
select
	max(duration) -
    	min(duration) as time_diff
from runner_orders;
```
| time_diff |
|-----------|
| 30        |

- _ The difference between the longest and shorted delivery time was 30 minutes._

6. ### What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
select
	runner_id,
    	order_id,
    	round(avg(distance / duration), 2) as speed,
    	concat(round(avg(distance / (duration / 60))), ' Km/hr') as `speed(Km/hr)`
from runner_orders
where pickup_time is not null
group by 1, 2
order by 1, 2;
```
| runner_id | order_id | speed | speed(Km/hr) |
|-----------|----------|-------|--------------|
| 1         | 1        | 0.62  | 38 Km/hr     |
| 1         | 2        | 0.74  | 44 Km/hr     |
| 1         | 3        | 0.67  | 40 Km/hr     |
| 1         | 10       | 1     | 60 Km/hr     |
| 2         | 4        | 0.58  | 35 Km/hr     |
| 2         | 7        | 1     | 60 Km/hr     |
| 2         | 8        | 1.56  | 94 Km/hr     |
| 3         | 5        | 0.67  | 40 Km/hr     |

- _The average speed of a runner increases as the number of orders they have increases._
- _Runner 2 really picked up the speed from his first delivery to his third delivery._

7. ### What is the successful delivery percentage for each runner?
```sql
select
	runner_id,
    	concat(round((sum(case when pickup_time is null then 0 else 1 end) / count(*) * 100)), '%') as successfull_delivery_rate
from runner_orders
group by 1;
```
| runner_id | successfull_delivery_rate |
|-----------|---------------------------|
| 1         | 100%                      |
| 2         | 75%                       |
| 3         | 50%                       |

- _The first runner had a 100% delivery rate, while the others did not._
- _This is because both runner 2, and 3 had cancelled orders_

---

## C. Ingredient Optimisation

> Some of the queries for section c are extremly long, you will have to click on `view result:` to the see the query and the result.
</br>

1. ### What are the standard ingredients for each pizza?
<details>
<summary>
view result:
</summary>
```sql
with recursive num as
	(
    select 1 as n
union
	select
		n + 1
	from num where n < 10
    )
select
	pizza_name,
	group_concat(topping_name separator ', ') as topping_name
from num
join pizza_recipes as pr
	on n <= length(toppings) - length(replace(toppings, ',', '')) + 1
join pizza_toppings as pt
	on pt.topping_id = substring_index(substring_index(toppings, ',', n), ',', -1)
join pizza_names as pn
	on pn.pizza_id = pr.pizza_id
group by 1
order by pizza_name;

| pizza_name | topping_name                                                          |
|------------|-----------------------------------------------------------------------|
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

</details>











---

## D. Pricing and Ratings
