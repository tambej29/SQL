# Case Study #1 - Denny's Diner

<p align="left">
<img src="https://github.com/tambej29/SQL/assets/68528130/95f5b610-5bb7-4dc7-83f4-53121ce4129d" width=70% hight=70%>

## Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

## Datasets
### [sales](https://github.com/tambej29/SQL/blob/main/Case%201%20Denny's%20Dinner/Datasets/sales.csv)  
The ```sales``` table captures all the ```customer id``` purchases with an ```order date``` and ```product id``` information for when and what menu items were ordered.

### [menu](https://github.com/tambej29/SQL/blob/main/Case%201%20Denny's%20Dinner/Datasets/menu.csv)
The ```menu``` table maps the ```product id``` to the actual ```product name``` and ```price``` of each menu item.

### [members](https://github.com/tambej29/SQL/blob/main/Case%201%20Denny's%20Dinner/Datasets/members.csv)
The final ```members``` table captures the ```join date``` when a ```customer id``` joined the beta version of the Danny’s Diner loyalty program.

## Entity Relationship Diagram
![image](https://github.com/tambej29/SQL/assets/68528130/85b01b6c-dba9-4a94-a0bb-d825b10bb51f)

## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Bonus Questions
<details>
<summary>
Join All The Things
</summary>
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

_Recreate the following table output using the available data:_

<img src="https://github.com/tambej29/SQL/assets/68528130/0eb8c733-3756-409a-b57a-5ed627170934" width=50% hight=50%>

</details>

<details>
<summary>
Rank All Things
</summary>
  
Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.
<img src="https://github.com/tambej29/SQL/assets/68528130/671a79d2-1191-4cad-af43-6adb57adf3ed" width=50% hight=50%>

</details>

#  

[Case 1  Denny's Dinner result](https://github.com/tambej29/SQL/blob/main/Case%201%20Denny's%20Dinner/Denny's%20case%201%20result.md)

[Case 1 Denney's Dinner SQL script](https://github.com/tambej29/SQL/blob/main/Case%201%20Denny's%20Dinner/Denny's%20Case%201%20Script.sql)

#

[8 Week SQL Challenge](https://8weeksqlchallenge.com)

