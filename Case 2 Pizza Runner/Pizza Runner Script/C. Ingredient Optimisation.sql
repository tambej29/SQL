/*					Pizza Runners					*/

/*--------------C.Ingredient Optimisation--------------*/

-- 1: What are the standard ingredients for each pizza?

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
order by pizza_name;  /* This is if there are asking the recipes for each pizza, then this solution works.*/

with recursive num as
	(
    select 1 as n
union
	select
		n + 1
	from num where n < 10
    ),
toppings as
	(
    select
		pizza_id,
		substring_index(substring_index(toppings, ',', n), ',', -1) as topping_id
	from num
	join pizza_recipes as pr
		on n <= length(toppings) - length(replace(toppings, ',', '')) + 1
	join pizza_toppings as pt
		on pt.topping_id = substring_index(substring_index(toppings, ',', n), ',', -1)
    )
select
	topping_name
from toppings
join pizza_toppings using(topping_id)
group by 1
having count(distinct pizza_id) > 1; /* This solution is if they are asking which toppings do both pizza share. */

-- 2: What was the most commonly added extra?
select
	count(extra_topping) as cnt,
	topping_name
from customer_orders,
json_table(
	concat('["', replace(extras, ',', '","'), '"]'), '$[*]' columns(extra_topping int path '$')) as jt
join pizza_toppings
	on topping_id = extra_topping
group by 2
order by 1 desc limit 1; -- Bancon was the most added extra

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
set sql_mode=PIPES_AS_CONCAT;
with exclusions as
	(
    select
		order_id,
        pizza_id,
        exclusions,
        group_concat(distinct topping_name separator ', ') as topping_name
	from customer_orders as co,
    json_table(
		concat('["', replace(exclusions, ',', '","'), '"]'), '$[*]' columns(exc_topping_id int path '$')) as jt
	join pizza_toppings as pt
		on pt.topping_id = exc_topping_id
	group by 1, 2, 3
	),
extras as
	(
    select
		order_id,
        pizza_id,
        extras,
        group_concat(distinct topping_name separator ', ') as topping_name
	from customer_orders as co,
    json_table(
		concat('["', replace(extras, ',', '","'), '"]'), '$[*]' columns(ex_topping_id int path '$')) as jt
	join pizza_toppings as pt
		on pt.topping_id = ex_topping_id
	group by 1, 2, 3
	)
select
	co.order_id,
    concat_ws(' ', case when pizza_name = 'Meatlovers' then 'Meat Lovers' else pizza_name end,
		coalesce('- Exclude ' || exc.topping_name, ''),
        coalesce('- Extra ' || ex.topping_name), '') as order_details
from customer_orders as co
left join exclusions as exc
	on co.order_id = exc.order_id and co.pizza_id = exc.pizza_id and co.exclusions = exc.exclusions
left join extras as ex
	on co.order_id = ex.order_id and co.pizza_id = ex.pizza_id and co.extras = ex.extras
left join pizza_names as pn
	on pn.pizza_id = co.pizza_id;

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
        exclusions,  
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
        extras,     
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
	from pizza_recipes as pr  
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
	from orders as o           
	left join exclud as ex
		on o.order_id = ex.order_id and o.pizza_id = ex.pizza_id and o.topping_id = ex.topping_id
	where ex.topping_id is null -- Removes all the excluded toppings

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
		pizza_name,   
		topping_name,
		count(topping_id) as num -- Count topping_id which will  be use fot the 2x, 3x ect..
	from order_detail 
	join pizza_names as pn using(pizza_id)
	group by 1,2,3)
-- Use case statement to replace 'Meatlovers' with 'Meat Lovers' then
-- use group_concat to nest all the topping_names to their respected pizzas.
-- Use conditional statement to add a multiplier to any topping_name with a num > 1 and order topping_name alphabetically
-- All of these should be withing a concat() to concatinate pizza_name and topping_name as shown below.
select
	order_id,
    concat_ws(': ',case when pizza_name = 'Meatlovers' then 'Meat lovers' else pizza_name end,
    group_concat(case
		when num > 1 then num || 'x' || topping_name
        else topping_name
        end order by topping_name separator ', ')) as incgredients
from result
group by order_id, pizza_name;

-- Using JSON_TABLE()
with excluded as 
	(
    select
		order_id,
		pizza_id,
		excluded_id, -- This is the column that will hold the values unnested from exclusions.
        exclusions,
        topping_name as excluded_topping
	from customer_orders as co,
    json_table(
		concat('["', replace(exclusions, ',', '","'), '"]'), '$[*]' columns(excluded_id int path '$')) jt
        -- The above code will turn exclusion into a json like format, and will put the unnested values into excluded_id.
	join pizza_toppings as pt
		on topping_id = excluded_id
	),
extras as
	(
    select
		order_id,
		pizza_id,
        extras,
		extra_id, -- This column will house the unnested values from extras
        topping_name as extra_topping
	from customer_orders as co,
    json_table(
		concat('["', replace(extras, ',', '","'), '"]'), '$[*]' columns(extra_id int path '$')) jt
        -- The above code will turn extras into a json like format, and will put the unnested values into extra_id.
	join pizza_toppings as pt
		on topping_id = extra_id
	),
pre_orders as
	(
    select
        pizza_id,
        extraced_topping_id,
        topping_name
	from pizza_recipes as pr,
    json_table(
		concat('["', replace(toppings, ',', '","'), '"]'), '$[*]' columns(extraced_topping_id int path '$')) as jt
	join pizza_toppings as pt
		on pt.topping_id = extraced_topping_id
    ),
-- Orders, is join customer_orders with pre_orders so each ordered pizza will have their ingredients listed
orders as
	(
    select
		order_id,
        co.pizza_id,
        exclusions,
        extras,
        extraced_topping_id as topping_id,
        topping_name
	from pre_orders as po
    join customer_orders as co
		on co.pizza_id = po.pizza_id
	),
-- Order_details will first join excluded to orders in order to filter out excluded toppings 
-- Then Union extras to add in the extra toppings
order_details as
	(
	select
		o.order_id,
        o.pizza_id,
		o.extras,
        topping_id,
        topping_name
	from orders as o
    left join excluded as exc
		on o.pizza_id = exc.pizza_id and o.order_id = exc.order_id and o.topping_id = exc.excluded_id
	where excluded_topping is null
union all
	select
		order_id,
        pizza_id,
        extras,
        extra_id as topping_id,
        extra_topping as topping_name
	from extras
	),
result as
	(
    select
		order_id,
        pizza_name,
        extras,
        topping_name,
        count(topping_id) as num -- Count the number of toppping which will be used to specify extras toppings
	from order_details as od
    join pizza_names as pn using(pizza_id)
    group by 1, 2, 3, 4
    )
-- Use case statement to replace 'Meatlovers' with 'Meat Lovers' then
-- use group_concat to nest all the topping_names to their respected pizzas.
-- Use conditional statement to add a multiplier to any topping_name with a num > 1 and order topping_name alphabetically
-- All of these should be withing a concat() to concatinate pizza_name and topping_name as shown below.
select
	order_id,
    concat_ws(': ', case when pizza_name = 'Meatlovers' then 'Meat Lovers' else pizza_name end,
		group_concat(case when num > 1 then num || 'x' || topping_name else topping_name end 
        order by topping_name separator ', ')) as ingredients
from result
group by order_id, pizza_name, extras;


/*-- 6: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?*/
with excluded as 
	(
    select
		order_id,
		pizza_id,
		excluded_id,
        exclusions,
        topping_name as excluded_topping
	from customer_orders as co,
    json_table(
		concat('["', replace(exclusions, ',', '","'), '"]'), '$[*]' columns(excluded_id int path '$')) jt
	join pizza_toppings as pt
		on topping_id = excluded_id
	),
extras as
	(
    select
		order_id,
		pizza_id,
        extras,
		extra_id,
        topping_name as extra_topping
	from customer_orders as co,
    json_table(
		concat('["', replace(extras, ',', '","'), '"]'), '$[*]' columns(extra_id int path '$')) jt
	join pizza_toppings as pt
		on topping_id = extra_id
	),
pre_orders as
	(
    select
        pizza_id,
        extraced_topping_id,
        topping_name
	from pizza_recipes as pr,
    json_table(
		concat('["', replace(toppings, ',', '","'), '"]'), '$[*]' columns(extraced_topping_id int path '$')) as jt
	join pizza_toppings as pt
		on pt.topping_id = extraced_topping_id
    ),
orders as
	(
    select
		order_id,
        co.pizza_id,
        extraced_topping_id as topping_id,
        topping_name
	from pre_orders as po
    join customer_orders as co
		on co.pizza_id = po.pizza_id
	),
order_details as
	(
	select
		o.order_id,
        o.pizza_id,
        topping_id,
        topping_name
	from orders as o
    left join excluded as exc
		on o.pizza_id = exc.pizza_id and o.order_id = exc.order_id and o.topping_id = exc.excluded_id
	where excluded_topping is null
union all
	select
		order_id,
        pizza_id,
        extra_id as topping_id,
        extra_topping as topping_name
	from extras
	)
select
	topping_name,
	count(topping_id) as total_ingredients_used
from order_details as od
join runner_orders as ro using(order_id)
where pickup_time is not null
group by 1
order by 2 desc;