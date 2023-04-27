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
group by order_id, topping_name;

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
