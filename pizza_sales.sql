
CREATE TABLE pizzas(
	pizza_id VARCHAR(255) PRIMARY KEY,
	pizza_type_id VARCHAR(255),
	size VARCHAR(255),
	price NUMERIC(10,2)
)

SELECT * FROM pizzas;



CREATE TABLE pizza_types(
	pizza_type_id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255),
	category VARCHAR(255),
	ingredients TEXT
)

SELECT * FROM pizza_types;


CREATE TABLE orders(
	order_id INT PRIMARY KEY,
	date DATE,
	time TIME	
)
SELECT * FROM orders;



DROP TABLE IF EXISTS order_details;
CREATE TABLE order_details(
	order_details_id INT PRIMARY KEY,
	order_id INT,
	pizza_id VARCHAR(255),
	quantity INT	
)
SELECT * FROM order_details;


-- 1. Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_number_of_orders FROM orders;


-- 2.Calculate the total revenue generated from pizza sales.

SELECT SUM(pizzas.price * order_details.quantity) AS total_amount FROM pizzas JOIN order_details ON pizzas.pizza_id=order_details.pizza_id;



-- 3. Identify the highest-priced pizza.

SELECT * FROM pizzas WHERE price=( SELECT MAX(price) FROM pizzas LIMIT 1);


-- 4. Identify the most common pizza size ordered.

SELECT DISTINCT pizzas.size,COUNT(order_details.pizza_id) FROM pizzas JOIN order_details ON order_details.pizza_id=pizzas.pizza_id GROUP BY pizzas.size;


-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name,COUNT(order_details.quantity) AS total_quantity FROM order_details 
JOIN pizzas ON pizzas.pizza_id=order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id GROUP BY pizza_types.name ORDER BY total_quantity DESC LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category,SUM(order_details.quantity) AS total_quantity_category FROM order_details
JOIN pizzas ON pizzas.pizza_id=order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id GROUP BY pizza_types.category ORDER BY total_quantity_category DESC;



-- 7. Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM time) AS time,COUNT(order_id) AS quantity FROM orders GROUP BY EXTRACT(HOUR FROM time) ORDER BY quantity DESC ;



-- 8.Join relevant tables to find the category-wise distribution of pizzas.


SELECT category,COUNT(pizza_type_id) AS quantity FROM pizza_types GROUP BY category ORDER BY quantity DESC ;


-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT date,AVG(order_id) AS avg_pizza_order FROM orders GROUP BY date ORDER BY date ASC ;


-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name,SUM(order_details.quantity * pizzas.price) AS total_revenu FROM order_details 
JOIN pizzas ON pizzas.pizza_id=order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id GROUP BY pizza_types.name ORDER BY total_revenu DESC LIMIT 3;



-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.name,SUM(order_details.quantity * pizzas.price) * 100.0 /
    SUM(SUM(order_details.quantity * pizzas.price)) OVER () 
    AS total_revenue_percentage FROM order_details 
JOIN pizzas ON pizzas.pizza_id=order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id GROUP BY pizza_types.name ORDER BY total_revenue_percentage DESC;



-- 12. Analyze the cumulative revenue generated over time.


SELECT order_date,sum(total_revenue) over(ORDER BY order_date) AS cum_revenu
FROM (
SELECT orders.date AS order_date,SUM(order_details.quantity * pizzas.price)
    AS total_revenue FROM order_details 
JOIN pizzas ON pizzas.pizza_id=order_details.pizza_id
JOIN orders ON orders.order_id=order_details.order_id GROUP BY orders.date ORDER BY orders.date DESC)


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,revenu FROM
(SELECT category,name,revenu,rank() OVER(partition BY category ORDER BY revenu) AS rn
FROM
(SELECT pizza_types.category,pizza_types.name,SUM(order_details.quantity*pizzas.price) AS revenu FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id=pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) AS b WHERE rn<=3;

