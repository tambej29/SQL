-- Pizza Runner --

-- A. Pizza Metrics

Select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

/*----------A. Pizza Metrics----------*/

-- 1: How many pizzas were ordered?
select
	count(pizza_id) as pizza_ordered
from customer_orders;

-- 2: How many unique customer orders were made?
select
	count(distinct order_id) as unique_customer_orders
from customer_orders;

-- 3: How many successful orders were delivered by each runner?
select
	runner_id,
    count(order_id) as delivered_orders
from runner_orders
where pickup_time is not null
group by 1;

-- 4: How many of each type of pizza was delivered?

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

Select * from customer_orders;
select * from pizza_names;
select * from runner_orders;
-- 5: How many Vegetarian and Meatlovers were ordered by each customer?
select
	customer_id,
    count(case when pizza_name = 'meatlovers' then pizza_id end) as meatlovers_cnt,
    count(case when pizza_name = 'vegetarian' then pizza_id end) as vegetarian_cnt
from customer_orders as co
join pizza_names as pn using(pizza_id)
group by 1;
-- 6: What was the maximum number of pizzas delivered in a single order?
select
	ro.order_id,
    count(co.pizza_id) as delivered_pizza
from runner_orders as ro
join customer_orders as co
	using(order_id)
where ro.pickup_time is not null
group  by 1
order by 2 desc limit 1;

-- 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

-- 8: How many pizzas were delivered that had both exclusions and extras?

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

-- 9: What was the total volume of pizzas ordered for each hour of the day?
select
	extract(hour from order_time) as hour,
	count(pizza_id) as pizza_ordered
from customer_orders
group by 1
order by 2 desc;

-- 10: What was the volume of orders for each day of the week?
select
    dayname(order_time) as day,
	count(order_id) as pizza_ordered
from customer_orders
group by 1
order by 2 desc;
