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