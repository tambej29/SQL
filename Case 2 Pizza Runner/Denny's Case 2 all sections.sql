CREATE SCHEMA pizza_runner;
use pizza_runner;

DROP TABLE IF EXISTS runners;

CREATE TABLE runners (
  `runner_id` INTEGER,
  `registration_date` DATE
);

INSERT INTO runners
  (`runner_id`, `registration_date`)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders (
  `order_id` INTEGER,
  `customer_id` INTEGER,
  `pizza_id` INTEGER,
  `exclusions` VARCHAR(4),
  `extras` VARCHAR(4),
  `order_time` DATETIME
);


INSERT INTO customer_orders
  (`order_id`, `customer_id`, `pizza_id`, `exclusions`, `extras`, `order_time`)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;

CREATE TABLE runner_orders (
  `order_id` INTEGER,
  `runner_id` INTEGER,
  `pickup_time` VARCHAR(19),
  `distance` VARCHAR(7),
  `duration` VARCHAR(10),
  `cancellation` VARCHAR(23)
);


INSERT INTO runner_orders
  (`order_id`, `runner_id`, `pickup_time`, `distance`, `duration`, `cancellation`)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;

CREATE TABLE pizza_names (
  `pizza_id` INTEGER,
  `pizza_name` LONGTEXT
);

INSERT INTO pizza_names
  (`pizza_id`, `pizza_name`)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;

CREATE TABLE pizza_recipes (
  `pizza_id` INTEGER,
  `toppings` LONGTEXT
);

INSERT INTO pizza_recipes
  (`pizza_id`, `toppings`)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;

CREATE TABLE pizza_toppings (
  `topping_id` INTEGER,
  `topping_name` LONGTEXT
);

INSERT INTO pizza_toppings
  (`topping_id`, `topping_name`)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

Select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

-- we'll frist start by updating customer_orders and runner_orders
-- we'll update 'null' with actual Null values.

set sql_safe_updates = 0;
select * from customer_orders;
update customer_orders
set exclusions =
case when order_id = 10 then null 
end
where order_id = 10 and exclusions = 'null'
;
update customer_orders
set exclusions =
case when exclusions = 'null' then null 
end
where order_id in (5,6,7,8)
;
update customer_orders
set extras = 
case when extras = 'null' then null 
end
where order_id in (6,8)
;
update customer_orders
set extras =
case when order_id = 10 then null 
end
where order_id = 10 and extras = 'null';
select * from customer_orders;

-- Now we update runner_orders

select * from runner_orders;
update runner_orders
set cancellation =
case when cancellation = 'null' then null 
end
where order_id in (7,8,10)
;
update runner_orders
set duration =
case when duration = 'null' then null 
end
where order_id in (6,9)
;
update runner_orders
set distance =
case when distance = 'null' then null 
end
where order_id in (6,9)
;
update runner_orders
set pickup_time =
case when pickup_time = 'null' then null 
end
where order_id in (6,9)
;
-- Now lets check all the tables and begin answering questions.

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
	count(distinct order_id) as unique_cus_orders
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
    count(co.pizza_id) num_type_pizza_delivered
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
    pizza_name,
    count(co.pizza_id) as num_of_order
from customer_orders as co
join pizza_names as pa
	on co.pizza_id = pa.pizza_id
group by 1,2
order by 1;

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

Select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

-- 8: How many pizzas were delivered that had both exclusions and extras?

select
	pa.pizza_name,
    count(co.pizza_id) as delivered_pizza_with_exclu_extras
from customer_orders as co
join runner_orders as ro using (order_id)
join pizza_names as pa using (pizza_id)
where pickup_time is not null
and case
		when (exclusions is not null and length(exclusions) >0)
		and (extras is not null and length(extras) >0) Then 1
		else 0
		end
group by 1;



-- 9: What was the total volume of pizzas ordered for each hour of the day?
select
	extract(hour from order_time) as hour,
	count(pizza_id) as pizza_ordered
from customer_orders
group by extract(hour from order_time);

-- 10: What was the volume of orders for each day of the week?
select
	dayofweek(order_time) as day,
    dayname(order_time) as day_name,
	count(order_id) as pizza_ordered
from customer_orders
group by 1,2;


/* ----------B. Runner and Customer Experience----------*/

-- 1:How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select
	week(registration_date,1) as week,
    count(runner_id) as runner_signed_up
from runners
group by 1;

-- 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select
	runner_id,
    avg(abs(timestampdiff(minute,pickup_time, order_time))) as time_diff -- this one is calculating without the seconds, so just minutes
from runner_orders as ro
join customer_orders as co using (order_id)
where pickup_time is not null
group by 1;

select
	runner_id,
    time_format(avg(timediff(pickup_time, order_time)), '%i.%s') as time_diff -- this is the more accurate calculation as it takes into account the seconds.
from runner_orders as ro
join customer_orders as co using (order_id)
where pickup_time is not null
group by 1;

-- 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte as 
	(select
		ro.order_id,
		count(pizza_id) as ordered_pizza,
		timestampdiff(minute, co.order_time, ro.pickup_time) as time_diff
	from customer_orders as co
	join runner_orders as ro using (order_id)
	where pickup_time is not null
	group by 1,3)
select
	ordered_pizza,
    round(avg(time_diff), 0) as avg_prep
from cte
group by 1; -- It seems like 1 pizza takes about 12 minutes, 2 take about 18 minute, and 3 takes about 29 minutes to make.

-- 4: What was the average distance travelled for each customer?
select
	customer_id,
    round(avg(distance), 2) as avg_dis_travelled
from runner_orders as ro
join customer_orders as co using (order_id)
where pickup_time is not null
group by 1;

-- 5: What was the difference between the longest and shortest delivery times for all orders?
select
	max(duration) -
    min(duration) as time_diff
from runner_orders;

-- 6: What was the average speed for each runner for each delivery and do you notice any trend for these values?

select 
	runner_id,
	order_id,
    round(avg(distance / duration), 2) as speed
from runner_orders
where pickup_time is not null
group by 1,2
order by 1; -- It seems they run faster with each order, with runner 2 really picking up speed with each order.

-- 7: What is the successful delivery percentage for each runner?
with cte as
	(select
		runner_id,
		sum(case
			when pickup_time is null then 0
			else 1
			end) as order_delivered,
		count(order_id) as total_order
	from runner_orders
	group by 1)
select
	runner_id,
    round((order_delivered / total_order) * 100) as delivery_rate
from cte;

/*--------------C.Ingredient Optimisation--------------*/

-- 1: What are the standard ingredients for each pizza?

with recursive num (n) as
	(select 1
    union
    select n + 1
    from num where n <10),
    cte as
	(select
		pizza_id,
		ltrim(substring_index(substring_index(toppings, ',', n), ',', -1)) as topping_id
	from num as nu
	join pizza_recipes as pr
		on n <= char_length(toppings) - char_length(replace(toppings, ',', '')) + 1
	order by 1)
select
	pizza_name,
    GROUP_CONCAT(topping_name separator ', ') as toppings
from cte as c
join pizza_toppings as pt using (topping_id)
join pizza_names as pa on pa.pizza_id = c.pizza_id
group by 1;  /* This is if there are asking the recipes for each pizza, then this solution works.*/

with recursive num (n) as
	(select 1
    union
    select n + 1
    from num where n <10),
    cte as
	(select
		pizza_id,
		ltrim(substring_index(substring_index(toppings, ',', n), ',', -1)) as topping_id
	from num as nu
	join pizza_recipes as pr
		on n <= char_length(toppings) - char_length(replace(toppings, ',', '')) + 1
	order by 1)
 select
	topping_name
	-- count(distinct pizza_id) as pizza
 from cte as c
 join pizza_toppings as pt using (topping_id)
 group by 1
 having count(distinct pizza_id) > 1;  /* This solution is if they are asking which toppings do both pizza share. */

select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

-- 2: What was the most commonly added extra?
with RECURSIVE num (n) as
	(select 1
    union 
    SELECT n + 1
    from num where n < 10),
extra as
	(select
		pizza_id,
		ltrim(substring_index(substring_index(extras, ',', n), ',', -1)) as added_extra
	from customer_orders as co
    join num as n
		on n<= length(extras) - length(replace(extras, ',', '')) +1
	order by 1),
cte as
	(select
		topping_name,
         count(added_extra) x
	from extra as ex
    join pizza_toppings as pt on pt.topping_id = ex.added_extra
    group by 1)
select 
	topping_name
from cte
order by x desc limit 1; -- Bancon was the most added extra
        

select * from customer_orders;
select * from pizza_toppings;

-- 3: What was the most common exclusion?
 with RECURSIVE num (n) as
	(select 1
    union 
    SELECT n + 1
    from num where n < 10),
exclud as
	(select
		pizza_id,
		ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1)) as excluded
	from customer_orders as co
    join num as n
		on n<= length(exclusions) - length(replace(exclusions, ',', '')) +1
	order by 1),
cte as
	(select
		topping_name,
         count(excluded) x
	from exclud as e
    join pizza_toppings as pt on pt.topping_id = e.excluded
    group by 1)
select 
	topping_name
from cte
order by x desc limit 1; -- Chees was the most excluded topping.

/* 4: Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
with recursive num (n) as
	(select 1
    union
    select n + 1
    from num where n <3),
    excludes0 as
		(select
			order_id,
			pizza_id,
            exclusions,
			ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1)) as exclusion,
            topping_name
		from num as ex
		join customer_orders as co
			on n <= length(exclusions) - length(replace(exclusions, ',', '')) +1
		join pizza_toppings as pa on pa.topping_id = ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1))
		where exclusions is not null and exclusions <> ''
		order by 1, ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1))),
	excludes as
		(select
			order_id,
            pizza_id,
            exclusions,
            group_concat(distinct topping_name separator ', ') as excluded
		from excludes0
        group by 1,2,3),
    extra0 as
		(select
			order_id,
			pizza_id,
            extras,
			ltrim(substring_index(substring_index(extras, ',', n), ',', -1)) as extrass,
			topping_name
		from num as nu
		join customer_orders as co
			on n <= length(extras) - length(replace(extras, ',', '')) +1
		join pizza_toppings as pa on pa. topping_id = ltrim(substring_index(substring_index(extras, ',', n), ',', -1))
		where extras is not null and extras <> ''
		order by 1, ltrim(substring_index(substring_index(extras, ',', n), ',', -1))),
	extra as
		(select
			order_id,
            pizza_id,
            extras,
            group_concat(distinct topping_name separator ', ') as added_extra
		from extra0
        group  by 1,2,3)
select
	co.order_id,
    concat_ws(' ', case when pizza_name ='meatlovers' then 'Meat Lovers' else pizza_name end,
		coalesce('-Exclude ' || excluded, ''),
		coalesce('-Extra ' || added_extra, '')) as order_details
from customer_orders as co
left join excludes as ec on co.order_id = ec.order_id and co.pizza_id = ec.pizza_id and co.exclusions = ec.exclusions
left join extra as ex on co.order_id = ex.order_id and co.pizza_id = ex.pizza_id and co.extras = ex.extras
left join pizza_names as pn on co.pizza_id =  pn.pizza_id
where excluded is not null or added_extra is not null;
set sql_mode=PIPES_AS_CONCAT;

/*-- 5: Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/
Select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;


with RECURSIVE num (n) as
	(select 1
    union 
    SELECT n + 1
    from num where n < 10),
exclud as
	(select
		order_id,
		pizza_id,    -- generate a table with order_id, pizza_id, exclusions with their topping_id, and the name of excluded topping
        exclusions,  -- in general this table is for exclude toppings
		ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1)) as topping_id,
        topping_name as excluded
	from customer_orders as co
    join num as n
		on n<= length(exclusions) - length(replace(exclusions, ',', '')) +1
	join pizza_toppings as pt on pt.topping_id = ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1))
	order by 1),
extra as
	(select
		order_id,
		pizza_id,   -- generate a table with order_id, pizza_id, extras with their topping_id, and the name of extra topping
        extras,     -- and this is for axtra toppings
		ltrim(substring_index(substring_index(extras, ',', n), ',', -1)) as topping_id,
        topping_name as extrass
	from customer_orders as co
    join num as n
		on n<= length(extras) - length(replace(extras, ',', '')) +1
	join pizza_toppings as pt on pt.topping_id = ltrim(substring_index(substring_index(extras, ',', n), ',', -1))
	order by 1),
orders as
	(select
		order_id,
		pr.pizza_id,
		ltrim(substring_index(substring_index(toppings, ',', n), ',', -1)) as topping_id,
        topping_name
	from pizza_recipes as pr  -- now generate a table with the topping_id, and name for each ordered pizza
    join num as n
		on n<= length(toppings) - length(replace(toppings, ',', '')) +1
	join customer_orders as co on co.pizza_id = pr.pizza_id
    join pizza_toppings as pt on pt.topping_id = ltrim(substring_index(substring_index(toppings, ',', n), ',', -1))),
order_detail as
	(select
		o.order_id,
		o.pizza_id,
		o.topping_id,
		o.topping_name
	from orders as o           -- This table has excluded ingredient removed and extras added to order table
	left join exclud as ex
		on o.order_id = ex.order_id and o.pizza_id = ex.pizza_id and o.topping_id = ex.topping_id
	where ex.topping_id is null -- this is to find the ingredient that aren't being excluded

	union all

	select
		order_id,
		pizza_id,
		topping_id,
		extrass as topping_name
	from extra),
result as
	(select
		order_id,
		pizza_name,    -- this count topping to see which order will have added toppings
		topping_name,
		count(topping_id) as num
	from order_detail 
	join pizza_names as pn using(pizza_id)
	group by 1,2,3)
select
	order_id,
    concat_ws(': ',case when pizza_name = 'Meatlovers' then 'Meat lovers' else pizza_name end,
    group_concat(case
		when num > 1 then num || 'x' || topping_name
        else topping_name
        end order by topping_name separator ', ')) as incgredients
from result
group by 1;

/*-- 6: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?*/
with RECURSIVE num (n) as
	(select 1
    union 
    SELECT n + 1
    from num where n < 10),
exclud as
	(select
		order_id,
		pizza_id,    -- generate a table with order_id, pizza_id, exclusions with their topping_id, and the name of excluded topping
        exclusions,  -- in general this table is for exclude toppings
		ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1)) as topping_id,
        topping_name as excluded
	from customer_orders as co
    join num as n
		on n<= length(exclusions) - length(replace(exclusions, ',', '')) +1
	join pizza_toppings as pt on pt.topping_id = ltrim(substring_index(substring_index(exclusions, ',', n), ',', -1))
	order by 1),
extra as
	(select
		order_id,
		pizza_id,   -- generate a table with order_id, pizza_id, extras with their topping_id, and the name of extra topping
        extras,     -- and this is for axtra toppings
		ltrim(substring_index(substring_index(extras, ',', n), ',', -1)) as topping_id,
        topping_name as extrass
	from customer_orders as co
    join num as n
		on n<= length(extras) - length(replace(extras, ',', '')) +1
	join pizza_toppings as pt on pt.topping_id = ltrim(substring_index(substring_index(extras, ',', n), ',', -1))
	order by 1),
orders as
	(select
		order_id,
		pr.pizza_id,
		ltrim(substring_index(substring_index(toppings, ',', n), ',', -1)) as topping_id,
        topping_name
	from pizza_recipes as pr  -- now generate a table with the topping_id, and name for each ordered pizza
    join num as n
		on n<= length(toppings) - length(replace(toppings, ',', '')) +1
	join customer_orders as co on co.pizza_id = pr.pizza_id
    join pizza_toppings as pt on pt.topping_id = ltrim(substring_index(substring_index(toppings, ',', n), ',', -1))),
order_detail as
	(select
		o.order_id,
		o.pizza_id,
		o.topping_id,
		o.topping_name
	from orders as o           -- This table has excluded ingredient removed and extras added to order table
	left join exclud as ex
		on o.order_id = ex.order_id and o.pizza_id = ex.pizza_id and o.topping_id = ex.topping_id
	where ex.topping_id is null -- this is to find the ingredient that aren't being excluded

	union all

	select
		order_id,
		pizza_id,
		topping_id,
		extrass as topping_name
	from extra),
result as
	(select
		order_id,
		pizza_name,    -- this count topping to see which order will have added toppings
		topping_name,
		count(topping_id) as num
	from order_detail 
	join pizza_names as pn using(pizza_id)
	group by 1,2,3)
select
	topping_name,
    sum(num) as total_ingredients_used
from result
join runner_orders using(order_id)
where pickup_time is not null
group by 1
order by 2 desc;

/*-----------D. Pricing and Ratings-----------*/

Select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

-- 1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH CTE AS 
	(SELECT 
		order_id,
        pizza_id,
	CASE WHEN pizza_id =  1 then 12 else 10 end as pizza_cost
		from customer_orders)
SELECT
	SUM(pizza_cost) as total_revenue
from cte as c
JOIN runner_orders ro ON c.order_id = ro.order_id
where pickup_time is not null;


-- 2: What if there was an additional $1 charge for any pizza extras ex:Add cheese is $1 extra ?
with cte as
	(select
		order_id,
        pizza_id,
	case
		when pizza_id = 1 then 12 else 10
        end as price,
		extras
	from customer_orders
    join runner_orders using(order_id)
    where pickup_time is not null)
select
	sum(case
		when extras is null then price
        when extras = '' then price
        when length(replace(extras, ', ', '')) = 1 then price + 1
        else price + 2
        end) as total_price
from cte;

/* 3: The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional
 table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/
drop table if EXISTS rating;
create table rating
select
	order_id,
    case
		when duration is null then null
		when duration = 10 then 5
        when duration BETWEEN 15 and 20 then 4
        when duration BETWEEN 20 and 30 then 3
        when duration BETWEEN 30 and 35 then 2
        else 1
        end as rating
	from runner_orders;

-- 4: Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?*/
select
		co.customer_id,
		co.order_id,
		ro.runner_id,
		r.rating,
		co.order_time,
		ro.pickup_time,
        time_format(timediff(pickup_time, order_time), '%i.%s') as timediff,
        duration as delivery_time,
        round(avg(distance/duration),2) as avg_speed,
        count(pizza_id) as total_pizza
	from customer_orders as co
    join runner_orders as ro on co.order_id = ro.order_id
    join rating as r on r.order_id = co.order_id
    where pickup_time is not null
    group by 1,2,3,4,5,6,8;
select  * from customer_orders;
    
/* 5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
 - how much money does Pizza Runner have left over after these deliveries?*/

select
	@distance_travel_revenue:= sum(distance * .3)
from runner_orders
where pickup_time is not null;
with cte as
	(select
		ro.order_id,
		case when pizza_id = 1 then 12 else 10 
		end as price,
		distance
	from runner_orders as ro
	join customer_orders as co using (order_id)
	where pickup_time is not null)
select
	sum(price) - @distance_travel_revenue as profit
from cte;
     