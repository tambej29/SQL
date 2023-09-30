/*				Pizza Runners				 */

/* ----------B. Runner and Customer Experience----------*/

-- 1:How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select
	extract(week from registration_date + 3) as week,
    count(runner_id) as runner_cnt
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
    round(time_format(avg(timediff(pickup_time, order_time)), '%i.%s')) as avg_time -- this is the more accurate calculation as it takes into account the seconds.
from runner_orders 
join customer_orders using (order_id)
where pickup_time is not null
group by 1;

-- 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?
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
group by pizza_cnt; -- It seems like 1 pizza takes about 12 minutes, 2 take about 18 minute, and 3 takes about 29 minutes to make.

-- 4: What was the average distance travelled for each customer?
select
	customer_id,
    concat(round(avg(distance)), ' km') as avg_distance
from runner_orders
join customer_orders using(order_id)
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
    round(avg(distance / duration), 2) as speed,
    concat(round(avg(distance / (duration / 60))), ' Km/hr') as `speed(Km/hr)`
from runner_orders
where pickup_time is not null
group by 1, 2
order by 1, 2; -- It seems they run faster with each order, with runner 2 really picking up speed with each order.

-- 7: What is the successful delivery percentage for each runner?
select
	runner_id,
    concat(round((sum(case when pickup_time is null then 0 else 1 end) / count(*) * 100)), '%') as successfull_delivery_rate
from runner_orders
group by 1;