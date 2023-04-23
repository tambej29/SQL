CREATE SCHEMA dannys_diner;
use dannys_diner;

-- SQLINES LICENSE FOR EVALUATION USE ONLY
CREATE TABLE sales (
  `customer_id` VARCHAR(1),
  `order_date` DATE,
  `product_id` INTEGER
);

-- SQLINES LICENSE FOR EVALUATION USE ONLY
INSERT INTO sales
  (`customer_id`, `order_date`, `product_id`)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

-- SQLINES LICENSE FOR EVALUATION USE ONLY
CREATE TABLE menu (
  `product_id` INTEGER,
  `product_name` VARCHAR(5),
  `price` INTEGER
);

-- SQLINES LICENSE FOR EVALUATION USE ONLY
INSERT INTO menu
  (`product_id`, `product_name`, `price`)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

-- SQLINES LICENSE FOR EVALUATION USE ONLY
CREATE TABLE members (
  `customer_id` VARCHAR(1),
  `join_date` DATE
);

-- SQLINES LICENSE FOR EVALUATION USE ONLY
INSERT INTO members
  (`customer_id`, `join_date`)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from members;
select * from menu;
select * from sales;

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select
	s.customer_id as customer, sum(m.price) as total_spent
from sales as s
join menu as m
	using (product_id)
group by 1
order by 2 desc;

-- 2. How many days has each customer visited the restaurant?

select
	customer_id as customer, count(distinct order_date) as visit_days
from sales
group by 1
order by 2 desc;

-- 3. What was the first item from the menu purchased by each customer?

select
	distinct s.customer_id as customer,
	first_value(m.product_name) over (partition by s.customer_id order by order_date asc) as first_buy
from sales as s
join menu as m
	using (product_id);

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select
	m.product_name, count(product_id) as Num_time_purchased
from menu as m
join sales as s
	using(product_id)
group by 1
order by 2 desc limit 1;

-- 5. Which item was the most popular for each customer?

select
	customer, product_name
from 
	(select
		s.customer_id as customer, product_name, count(s.product_id),
		rank() over (partition by s.customer_id order by count(s.product_id) desc) as rk
	from sales as s
	join menu as m
		using(product_id)
	group by 1, 2) as sbqry
where sbqry.rk = 1;

-- 6. Which item was purchased first by the customer after they became a member?

select * from members;
select * from menu;
select * from sales;

select
	customer, product_name
from 
	(select
		mb.customer_id as customer, m.product_name, s.order_date, s.product_id,
		row_number() over (partition by mb.customer_id order by s.order_date asc) as rn
	from members as mb
	join sales as s
		on mb.customer_id = s.customer_id
	join menu as m
		on m.product_id = s.product_id
	where order_date >= join_date) as sbqry
where sbqry.rn = 1;

-- 7. Which item was purchased just before the customer became a member?

select 
	customer, product_name
from
	(select
		mb.customer_id as customer, product_name, s.order_date, s.product_id,
		last_value(m.product_name) over (partition by mb.customer_id order by s.order_date 
												 range between UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as lv,
		rank() over (partition by s.customer_id order by s.order_date desc) as rnk
	from members as mb
	join sales as s
		on mb.customer_id = s.customer_id
	join menu as m
		on m.product_id = s.product_id
	where s.order_date < mb.join_date) as sbqry
where sbqry.rnk = 1;

select -- Using Case Statement
	customer, product_name as first_purchased
from 
	(select
		mb.customer_id as customer, product_name, s.order_date,
	case
		when mb.customer_id = 'a' and lag(order_date) over(partition by mb.customer_id order by order_date asc) then 'yes'
		when mb.customer_id = 'b' and lag(order_date,2) over(partition by mb.customer_id order by order_date asc) then 'yes'
		else null 
        end as x
	from members as mb
	join sales as s
		on mb.customer_id = s.customer_id
	join menu as m
		on m.product_id = s.product_id
	where s.order_date not between mb.join_date and s.order_date) as sbqry
where sbqry.x is not null;

-- 8. What is the total items and amount spent for each member before they became a member?

select * from members;
select * from menu;
select * from sales;

select
	mb.customer_id as customer, count(*) as total_items, sum(price) as amount_spent
from members as mb
join sales as s
	on mb.customer_id = s.customer_id
join menu as m
	on m.product_id = s.product_id
where s.order_date not between mb.join_date and s.order_date
GROUP BY 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select
	customer_id,
	sum(case when product_name = 'sushi' then price * 10 * 2
			else price * 10
            end) as points
from menu as m
join sales as s
	using(product_id)
GROUP BY 1;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select
	mb.customer_id,
	sum(case when order_date BETWEEN mb.join_date and date_add(mb.join_date, interval 6 day) then price * 10 * 2
			 when product_name = 'sushi' then price * 10 * 2
             else price * 10
            end) as points
from menu as m
join sales as s
	using(product_id)
join members as mb
	on mb.customer_id = s.customer_id
where extract(year_month from order_date) ='202101'
group by 1;

-- Bonus Quentions --
-- Join all Things --

create view `Customer/Member view`
as
select
	s.customer_id, s.order_date, m.product_name, price,
	case when mb.join_date is null then 'N'
		 when s.order_date >= mb.join_date then 'Y'
		 else 'N'
    end as member
from members as mb
right join sales as s
	using (customer_id)
join menu as m
	using(product_id)
order by 1,2;

select * from `customer/member view`;

-- Ranking All Things --

select *,
case when member = 'y' then rank() over (partition by customer_id, member order by order_date)
	 else null
     end as ranking
from
	(select
		s.customer_id, s.order_date, m.product_name, price,
		case when mb.join_date is null then 'N' 
			 when s.order_date >= mb.join_date then 'Y'
		else 'N'
		end as member
	from members as mb
	right join sales as s
		using (customer_id)
	join menu as m
		using(product_id)
	order by 1,2) as sbqry;

