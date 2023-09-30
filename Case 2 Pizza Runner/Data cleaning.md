# Pizza Runner Data Cleaning


The datasets are faily cleaned, and well structured. Only `customer_orders` and `runner_orders` need to be slightly modified. Rows with `NULL` are artually NULL values, were as rows with "null" are just null typed out. Row with "null" will be modiefied to `NULL`.


## Datasets:

```customer_orders```
| order_id | customer_id | pizza_id | exclusions | extras | order_time          |
|----------|-------------|----------|------------|--------|---------------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02 |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52 |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23 |
| 3        | 102         | 2        |            |`NULL`  | 2020-01-02 23:51:23 |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46 |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46 |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46 |
| 5        | 104         | 1        | null       | 1      | 2020-01-08 21:00:29 |
| 6        | 101         | 2        | null       | null   | 2020-01-08 21:03:13 |
| 7        | 105         | 2        | null       | 1      | 2020-01-08 21:20:29 |
| 8        | 102         | 1        | null       | null   | 2020-01-09 23:54:33 |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59 |
| 10       | 104         | 1        | null       | null   | 2020-01-11 18:34:49 |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49 |

```pizza_names```
| pizza_id | pizza_name |
|----------|------------|
| 1        | Meatlovers |
| 2        | Vegetarian |

```pizza_receipes```
| pizza_id | toppings                |
|----------|-------------------------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | 4, 6, 7, 9, 11, 12      |

```pizza_toppings```
| topping_id | topping_name |
|------------|--------------|
| 1          | Bacon        |
| 2          | BBQ Sauce    |
| 3          | Beef         |
| 4          | Cheese       |
| 5          | Chicken      |
| 6          | Mushrooms    |
| 7          | Onions       |
| 8          | Pepperoni    |
| 9          | Peppers      |
| 10         | Salami       |
| 11         | Tomatoes     |
| 12         | Tomato Sauce |

```runner_orders```
| order_id | runner_id | pickup_time         | distance | duration   | cancellation            |
|----------|-----------|---------------------|----------|------------|-------------------------|
| 1        | 1         | 2020-01-01 18:15:34 | 20km     | 32 minutes |                         |
| 2        | 1         | 2020-01-01 19:10:54 | 20km     | 27 minutes |                         |
| 3        | 1         | 2020-01-03 00:12:37 | 13.4km   | 20 mins    | `NULL `                 |
| 4        | 2         | 2020-01-04 13:53:03 | 23.4     | 40         | `NULL `                 |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15         | `NULL `                 |
| 6        | 3         | null                | null     | null       | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins     | null                    |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute  | null                    |
| 9        | 2         | null                | null     | null       | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes  | null                    |

```runners```
| runner_id | registration_date |
|-----------|-------------------|
| 1         | 2021-01-01        |
| 2         | 2021-01-03        |
| 3         | 2021-01-08        |
| 4         | 2021-01-15        |

---

## Update `customer_orders`:
I will leave blank rows as blank. It would normally be better to change them to `NULL`, but it will be more interesting to leave them blank.
```sql
update customer_orders
set 
  exclusions = 
    case when exclusions = 'null' then null else exclusions end,
  extras =
    case when extras = 'null' then null else extras end
;
```
<details>
<summary>
view result:
</summary>

| order_id | customer_id | pizza_id | exclusions | extras | order_time          |
|----------|-------------|----------|------------|--------|---------------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02 |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52 |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23 |
| 3        | 102         | 2        |            | `NULL` | 2020-01-02 23:51:23 |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46 |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46 |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46 |
| 5        | 104         | 1        | `NULL`     | 1      | 2020-01-08 21:00:29 |
| 6        | 101         | 2        | `NULL`     | `NULL` | 2020-01-08 21:03:13 |
| 7        | 105         | 2        | `NULL`     | 1      | 2020-01-08 21:20:29 |
| 8        | 102         | 1        | `NULL`     | `NULL` | 2020-01-09 23:54:33 |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59 |
| 10       | 104         | 1        | `NULL`     | `NULL` | 2020-01-11 18:34:49 |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49 |

</details>

## update `runner_orders`:
```sql
update runner_orders
set 
  pickup_time = case when pickup_time = 'null' then null else pickup_time end,
  distance = case when distance = 'null' then null else distance end,
  duration = case when duration = 'null' then null else duration end,
  cancellation = case when cancellation = 'null' then null else cancellation end
;
```
<details>
<summary>
view result:
</summary>

| order_id | runner_id | pickup_time         | distance | duration   | cancellation            |
|----------|-----------|---------------------|----------|------------|-------------------------|
| 1        | 1         | 2020-01-01 18:15:34 | 20km     | 32 minutes |                         |
| 2        | 1         | 2020-01-01 19:10:54 | 20km     | 27 minutes |                         |
| 3        | 1         | 2020-01-03 00:12:37 | 13.4km   | 20 mins    | `NULL`                  |
| 4        | 2         | 2020-01-04 13:53:03 | 23.4     | 40         | `NULL`                  |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15         | `NULL`                  |
| 6        | 3         | `NULL`              | `NULL`   | `NULL`     | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins     | `NULL`                  |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute  | `NULL`                  |
| 9        | 2         | `NULL`              | `NULL`   | `NULL`     | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes  | `NULL`                  |

</details>

---

This will be all for the data cleaing.









