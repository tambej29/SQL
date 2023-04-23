use projects;
/* We'll insect the data*/

select * from apple;
select * from facebook;
select * from google;
select * from nvidia;
select * from tesla;
select * from twitter; 

/* Ok, using STR_TO_DATE function, we will alter the datatype of date to an actual date format
for all the 6 tables. */

set sql_safe_updates = 0;
update apple
set date = str_to_date(date, '%m/%d/%Y');

set sql_safe_updates = 0;
update facebook
set date = str_to_date(date, '%m/%d/%Y');

set sql_safe_updates = 0;
update google
set date = str_to_date(date, '%m/%d/%Y');

set sql_safe_updates = 0;
update nvidia
set date = str_to_date(date, '%m/%d/%Y');

set sql_safe_updates = 0;
update tesla
set date = str_to_date(date, '%m/%d/%Y');

set sql_safe_updates = 0;
update twitter
set date = str_to_date(date, '%m/%d/%Y');
set sql_safe_updates = 1;

/* Now, we'll rename the tables, and we will use the original names to create new
tables with the the fields we will add. */

alter table apple
rename to app;
alter table facebook
rename to book;
alter table google
rename to goo;
alter table nvidia
rename to nvi;
alter table tesla
rename to tes;
alter table twitter
rename to twi;

/* Ok, we'll create new tables with these fields added:
MA50, MA200, previous day close, change in price, percent change in price,
privious day volume, change in volumne, percent change in volume. */

create table Apple
with MA as 
(select *,
	row_number() over (order by date asc) as rn,
    avg(close) over(order by date asc rows between 49 preceding and current row) as MA50,
	avg(close) over(order by date asc rows between 199 preceding and current row) as MA200,
	lag(close) over(order by date) as `previous day close`,
    lag(volume) over(order by date) as `previous day volume`
from app)
select
	date, open, high, low, close, `adj close`, volume,
case
	when rn > 49 then ma50
    else null
    end as MA50,
case
	when rn > 199 then ma200
    else null
    end as MA200,
    `previous day close`,
    close - `previous day close` as `change in price`,
    (close - `previous day close`) / `previous day close` as `percent change in price`,
	`previous day volume`,
    volume - `previous day volume` as `change in volume`,
    (volume - `previous day volume`) / `previous day volume` as `percent change in volume`
 from MA;
 drop table app;
 
 
create table Facebook
with MA as 
(select *,
	row_number() over (order by date asc) as rn,
    avg(close) over(order by date asc rows between 49 preceding and current row) as MA50,
	avg(close) over(order by date asc rows between 199 preceding and current row) as MA200,
	lag(close) over(order by date) as `previous day close`,
    lag(volume) over(order by date) as `previous day volume`
from book)
select
	date, open, high, low, close, `adj close`, volume,
case
	when rn > 49 then ma50
    else null
    end as MA50,
case
	when rn > 199 then ma200
    else null
    end as MA200,
    `previous day close`,
    close - `previous day close` as `change in price`,
    (close - `previous day close`) / `previous day close` as `percent change in price`,
	`previous day volume`,
    volume - `previous day volume` as `change in volume`,
    (volume - `previous day volume`) / `previous day volume` as `percent change in volume`
 from MA;
 drop table book;
 
 
create table Google
with MA as 
(select *,
	row_number() over (order by date asc) as rn,
    avg(close) over(order by date asc rows between 49 preceding and current row) as MA50,
	avg(close) over(order by date asc rows between 199 preceding and current row) as MA200,
	lag(close) over(order by date) as `previous day close`,
    lag(volume) over(order by date) as `previous day volume`
from goo)
select
	date, open, high, low, close, `adj close`, volume,
case
	when rn > 49 then ma50
    else null
    end as MA50,
case
	when rn > 199 then ma200
    else null
    end as MA200,
    `previous day close`,
    close - `previous day close` as `change in price`,
    (close - `previous day close`) / `previous day close` as `percent change in price`,
	`previous day volume`,
    volume - `previous day volume` as `change in volume`,
    (volume - `previous day volume`) / `previous day volume` as `percent change in volume`
 from MA;
 drop table goo;
 
 
create table Nvidia
with MA as 
(select *,
	row_number() over (order by date asc) as rn,
    avg(close) over(order by date asc rows between 49 preceding and current row) as MA50,
	avg(close) over(order by date asc rows between 199 preceding and current row) as MA200,
	lag(close) over(order by date) as `previous day close`,
    lag(volume) over(order by date) as `previous day volume`
from nvi)
select
	date, open, high, low, close, `adj close`, volume,
case
	when rn > 49 then ma50
    else null
    end as MA50,
case
	when rn > 199 then ma200
    else null
    end as MA200,
    `previous day close`,
    close - `previous day close` as `change in price`,
    (close - `previous day close`) / `previous day close` as `percent change in price`,
	`previous day volume`,
    volume - `previous day volume` as `change in volume`,
    (volume - `previous day volume`) / `previous day volume` as `percent change in volume`
 from MA;
 drop table nvi;
 
 create table Tesla
with MA as 
(select *,
	row_number() over (order by date asc) as rn,
    avg(close) over(order by date asc rows between 49 preceding and current row) as MA50,
	avg(close) over(order by date asc rows between 199 preceding and current row) as MA200,
	lag(close) over(order by date) as `previous day close`,
    lag(volume) over(order by date) as `previous day volume`
from tes)
select
	date, open, high, low, close, `adj close`, volume,
case
	when rn > 49 then ma50
    else null
    end as MA50,
case
	when rn > 199 then ma200
    else null
    end as MA200,
    `previous day close`,
    close - `previous day close` as `change in price`,
    (close - `previous day close`) / `previous day close` as `percent change in price`,
	`previous day volume`,
    volume - `previous day volume` as `change in volume`,
    (volume - `previous day volume`) / `previous day volume` as `percent change in volume`
 from MA;
 drop table tes;
 
 
 create table Twitter
with MA as 
(select *,
	row_number() over (order by date asc) as rn,
    avg(close) over(order by date asc rows between 49 preceding and current row) as MA50,
	avg(close) over(order by date asc rows between 199 preceding and current row) as MA200,
	lag(close) over(order by date) as `previous day close`,
    lag(volume) over(order by date) as `previous day volume`
from twi)
select
	date, open, high, low, close, `adj close`, volume,
case
	when rn > 49 then ma50
    else null
    end as MA50,
case
	when rn > 199 then ma200
    else null
    end as MA200,
    `previous day close`,
    close - `previous day close` as `change in price`,
    (close - `previous day close`) / `previous day close` as `percent change in price`,
	`previous day volume`,
    volume - `previous day volume` as `change in volume`,
    (volume - `previous day volume`) / `previous day volume` as `percent change in volume`
 from MA;
 drop table twi;

-- Let's see if everything is good.

select * from apple;
select * from facebook;
select * from google;
select * from nvidia;
select * from tesla;
select * from twitter; 

-- Ok, our data is good to be imported for analyst.