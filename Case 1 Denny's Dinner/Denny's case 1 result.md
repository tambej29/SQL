# Denny's Dinner Result

<img src="https://github.com/tambej29/SQL/assets/68528130/4e1c0460-d029-4ff8-af69-69121622857d" width=70% hight=70%>

## 1. What is the total amount each customer spent at the restaurant?
```sql
select
	s.customer_id as customer, 
    concat('$', sum(m.price)) as total_spent
from sales as s
join menu as m
	using (product_id)
group by 1
order by 2 desc;
```
| customer | total_spent |
|----------|-------------|
| A        | $76         |
| B        | $74         |
| C        | $36         |

## 2. How many days has each customer visited the restaurant?
```sql
select
	customer_id as customer, count(distinct order_date) as visit_days
from sales
group by 1
order by 2 desc;
```
| customer | visit_days |
|----------|------------|
| B        | 6          |
| A        | 4          |
| C        | 2          |

## 3. What was the first item from the menu purchased by each customer?
```sql
select
	distinct s.customer_id as customer,
	first_value(m.product_name) over (partition by s.customer_id order by order_date asc) as first_order
from sales as s
join menu as m
	using (product_id);
```
| customer | first_order |
|----------|-------------|
| A        | sushi       |
| B        | curry       |
| C        | ramen       |

## 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
select
	m.product_name, count(product_id) as cnt_purchased
from menu as m
join sales as s
	using(product_id)
group by 1
order by 2 desc limit 1;
```
| product_name | cnt_purchased |
|--------------|---------------|
| ramen        | 8             |

## 5. Which item was the most popular for each customer?
```sql
select
	customer, product_name
from 
	(select
		s.customer_id as customer, product_name,
		rank() over (partition by s.customer_id order by count(s.product_id) desc) as rnk
	from sales as s
	join menu as m
		using(product_id)
	group by 1, 2) as sbqry
where sbqry.rnk = 1;
```
| customer | product_name |
|----------|--------------|
| A        | ramen        |
| B        | curry        |
| B        | sushi        |
| B        | ramen        |
| C        | ramen        |

## 6. Which item was purchased first by the customer after they became a member?
```sql
select
	customer, product_name
from 
	(select
		mb.customer_id as customer, m.product_name, s.order_date,
		row_number() over (partition by mb.customer_id order by s.order_date asc) as rn
	from members as mb
	join sales as s
		on mb.customer_id = s.customer_id
	join menu as m
		on m.product_id = s.product_id
	where order_date >= join_date) as sbqry
where sbqry.rn = 1;
```
| customer | product_name |
|----------|--------------|
| A        | curry        |
| B        | sushi        |

## 7. Which item was purchased just before the customer became a member?
```sql
select 
	customer, product_name
from
	(select
		mb.customer_id as customer, product_name,
		dense_rank() over (partition by s.customer_id order by s.order_date desc) as rnk
	from members as mb
	join sales as s
		on mb.customer_id = s.customer_id
	join menu as m
		on m.product_id = s.product_id
	where s.order_date < mb.join_date) as sbqry
where sbqry.rnk = 1;
```
| customer | product_name |
|----------|--------------|
| A        | sushi        |
| A        | curry        |
| B        | sushi        |

## 8. What is the total items and amount spent for each member before they became a member?
```sql
select
	mb.customer_id as customer, 
    	count(*) as total_items, 
    	concat('$', sum(price)) as amount_spent
from members as mb
join sales as s
	on mb.customer_id = s.customer_id
join menu as m
	on m.product_id = s.product_id
where s.order_date not between mb.join_date and s.order_date
GROUP BY 1;
```
| customer | total_items | amount_spent |
|----------|-------------|--------------|
| B        | 3           | $40          |
| A        | 2           | $25          |

## 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
select
	customer_id,
	sum(case when product_name = 'sushi' then (price * 20)
		else (price * 10)
            	end) as points
from menu as m
join sales as s
	using(product_id)
GROUP BY 1;
```
| customer_id | points |
|-------------|--------|
| A           | 860    |
| B           | 940    |
| C           | 360    |

## 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
select
	mb.customer_id,
	sum(case when order_date BETWEEN mb.join_date and date_add(mb.join_date, interval 6 day) then (price * 20)
    -- The above line will find all the orders placed on the day the customer joined the membership and 6 days after they joined and will give them 2x points on all items.
			when product_name = 'sushi' then (price * 20)
			else (price * 10)
			end) as points
from members as mb
left join sales as s 
	on mb.customer_id = s.customer_id
join menu as m 
	on m.product_id = s.product_id
where extract(year_month from order_date) ='202101' -- This will limit the date range to the month of January.
group by 1;
```
| customer_id | points |
|-------------|--------|
| B           | 820    |
| A           | 1370   |

--- 

<details>
<summary>
Bonus Question: Join All Things
</summary>
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

```sql
select
	s.customer_id, s.order_date, m.product_name, 
	concat('$', price) as price,
	case when s.customer_id not in (select customer_id from members) then 'N'
	-- The above line will limit customers to those that exist in the members table, therefor excluding customer C.
		 when s.order_date >= mb.join_date then 'Y'
		 else 'N'
	end as member
from members as mb
right join sales as s
	using (customer_id)
join menu as m
	using(product_id)
order by 1,2, 4 desc;
```
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | curry        | $15   | N      |
| A           | 2021-01-01 | sushi        | $10   | N      |
| A           | 2021-01-07 | curry        | $15   | Y      |
| A           | 2021-01-10 | ramen        | $12   | Y      |
| A           | 2021-01-11 | ramen        | $12   | Y      |
| A           | 2021-01-11 | ramen        | $12   | Y      |
| B           | 2021-01-01 | curry        | $15   | N      |
| B           | 2021-01-02 | curry        | $15   | N      |
| B           | 2021-01-04 | sushi        | $10   | N      |
| B           | 2021-01-11 | sushi        | $10   | Y      |
| B           | 2021-01-16 | ramen        | $12   | Y      |
| B           | 2021-02-01 | ramen        | $12   | Y      |
| C           | 2021-01-01 | ramen        | $12   | N      |
| C           | 2021-01-01 | ramen        | $12   | N      |
| C           | 2021-01-07 | ramen        | $12   | N      |

</details>

<details>
<summary>
Bonus Questions: Ranking All Things
</summary>
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

 ```sql
select *,
case when member = 'Y' then dense_rank() over (partition by customer_id, member order by order_date)
-- Partitioning by customer_id and member will allow dense_rank() to only count customer who are member.
	else null
	end as ranking
from
	(select
		s.customer_id, s.order_date, m.product_name, 
		concat('$', price) as price,
		case when s.customer_id not in (select customer_id from members) then 'N'
			when s.order_date >= mb.join_date then 'Y'
			else 'N'
			end as member
	from members as mb
	right join sales as s
		using (customer_id)
	join menu as m
		using(product_id)
	order by 1,2, 4 desc) as sbqry;
```
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | curry        | $15   | N      | NULL    |
| A           | 2021-01-01 | sushi        | $10   | N      | NULL    |
| A           | 2021-01-07 | curry        | $15   | Y      | 1       |
| A           | 2021-01-10 | ramen        | $12   | Y      | 2       |
| A           | 2021-01-11 | ramen        | $12   | Y      | 3       |
| A           | 2021-01-11 | ramen        | $12   | Y      | 3       |
| B           | 2021-01-01 | curry        | $15   | N      | NULL    |
| B           | 2021-01-02 | curry        | $15   | N      | NULL    |
| B           | 2021-01-04 | sushi        | $10   | N      | NULL    |
| B           | 2021-01-11 | sushi        | $10   | Y      | 1       |
| B           | 2021-01-16 | ramen        | $12   | Y      | 2       |
| B           | 2021-02-01 | ramen        | $12   | Y      | 3       |
| C           | 2021-01-01 | ramen        | $12   | N      | NULL    |
| C           | 2021-01-01 | ramen        | $12   | N      | NULL    |
| C           | 2021-01-07 | ramen        | $12   | N      | NULL    |

</details>











