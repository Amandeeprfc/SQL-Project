-- Basic:
/* Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
1 - Join the necessary tables to find the total quantity of each pizza category ordered.
2 - Determine the distribution of orders by hour of the day.
3 - Join relevant tables to find the category-wise distribution of pizzas.
4 - Group the orders by date and calculate the average number of pizzas ordered per day.
5 - Determine the top 3 most ordered pizza types based on revenue.

Advanced:
1 - Calculate the percentage contribution of each pizza type to total revenue.
2 - Analyze the cumulative revenue generated over time.
3 - Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/

use pizza;

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- 1 - Retrieve the total number of orders placed.
select count(order_id) as total_no_of_orders from orders;

-- 2 - Calculate the total revenue generated from pizza sales.
select round(sum(piz.price * od.quantity),2) as total_revenue 
from order_details od
inner join pizzas piz 
on 
od.pizza_id = piz.pizza_id;


-- 3 - Identify the highest-priced pizza.
select piz.price as highest_priced_pizza, pty.name
from pizzas piz 
inner join 
pizza_types pty 
on 
piz.pizza_type_id = pty.pizza_type_id
order by highest_priced_pizza desc limit 1;


-- 4 - Identify the most common pizza size ordered.
select sum(od.quantity) as total_quantity, piz.size
from pizzas piz 
inner join order_details od on piz.pizza_id = od.pizza_id
group by piz.size
order by total_quantity desc; 


-- 5 - List the top 5 most ordered pizza types along with their quantities.
select pty.name, sum(od.quantity) as quantities from pizza_types pty 
inner join pizzas piz on pty.pizza_type_id = piz.pizza_type_id
inner join order_details od on piz.pizza_id = od.pizza_id
group by pty.name
order by quantities desc
limit 5;

-- Intermediate:
-- 1 - Join the necessary tables to find the total quantity of each pizza category ordered.
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

use pizza;

select pt.category, sum(od.quantity) as Total_Quantity
from pizza_types pt 
inner join pizzas piz on pt.pizza_type_id = piz.pizza_type_id
inner join order_details od on piz.pizza_id = od.pizza_id
group by pt.category
order by Total_Quantity desc;

-- 2 - Determine the distribution of orders by hour of the day.
select hour(time) from order_details od inner join orders o on o.order_id = o.order_id;

select hour(time) as Hours, count(order_id) as order_details from orders
group by Hours;


-- 3 - Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) Name from pizza_types group by category;

select distinct(Name) as Name_of_Pizza, category from pizza_types;

-- 4 - Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(no_of_pizza) as avg_no_of_pizza from
(select day(o.date), sum(od.quantity) as no_of_pizza from orders o 
inner join order_details od 
on 
od.order_id = o.order_id 
group by o.date) as order_quantity;

-- 5 - Determine the top 3 most ordered pizza types based on revenue.

select (pty.name) as name_of_pizza, round(sum(piz.price * od.quantity),2) as revenue from pizzas piz
inner join order_details od on piz.pizza_id = od.pizza_id
inner join pizza_types pty on   piz.pizza_type_id = pty.pizza_type_id
group by name_of_pizza 
order by revenue desc 
limit 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pty.category AS type_of_pizza, 
    SUM(piz.price * od.quantity) AS total_revenue, 
    ROUND((SUM(piz.price * od.quantity) / 
          (SELECT SUM(piz.price * od.quantity) 
           FROM pizzas piz
           INNER JOIN order_details od ON piz.pizza_id = od.pizza_id) 
          ) * 100, 2) AS revenue_percentage
FROM pizzas piz
INNER JOIN order_details od ON piz.pizza_id = od.pizza_id
INNER JOIN pizza_types pty ON piz.pizza_type_id = pty.pizza_type_id
GROUP BY pty.category
ORDER BY total_revenue DESC;


-- Analyze the cumulative revenue generated over time.
-- 2 query is right approch and easy to understand

SELECT 
    (o.date) as dates,
    round(SUM(piz.price * od.quantity),2) AS daily_revenue,
    round(SUM(SUM(piz.price * od.quantity)) OVER (ORDER BY o.date),2) AS cumulative_revenue
FROM order_details od 
JOIN pizzas piz ON od.pizza_id = piz.pizza_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY dates
ORDER BY dates ;


select Dates, per_day_revenue,  
sum(per_day_revenue) OVER (order by Dates) as Cumulative_Revenue
from 
(select (o.date) as Dates, round(sum(piz.price * od.quantity),2) as per_day_revenue from pizzas piz
inner join order_details od on piz.pizza_id = od.pizza_id
inner join orders o on o.order_id = od.order_id
group by Dates) as sales_per_day; 

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, 
round(sum(piz.price * od.quantity),2) as per_day_revenue from pizzas piz
inner join order_details od on piz.pizza_id = od.pizza_id
inner join pizza_types pt on piz.pizza_type_id = pt.pizza_type_id
group by category;


select category, name, revenue from
(select category, name, revenue,
rank() over( partition by category order by revenue desc) as rn
from 
(select pt.name, pt.category, round(sum(piz.price * od.quantity),2) as revenue
from pizza_types pt 
inner join pizzas piz on pt.pizza_type_id = piz.pizza_type_id
inner join order_details od on piz.pizza_id = od.pizza_id
group by pt.name, pt.category) as a) as b
where rn <= 3; 

