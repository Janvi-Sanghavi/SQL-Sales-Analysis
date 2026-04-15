CREATE DATABASE sales_analysis;
USE sales_analysis;
CREATE TABLE raw_data(
	row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(50),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(2000),
    sales DECIMAL(10, 2)
);
SELECT COUNT(*) FROM train;
TRUNCATE TABLE raw_data;

INSERT INTO raw_data
SELECT 
    `Row ID`,
    `Order ID`,
    STR_TO_DATE(`Order Date`, '%d/%m/%Y'),
    STR_TO_DATE(`Ship Date`, '%d/%m/%Y'),
    `Ship Mode`,
    `Customer ID`,
    `Customer Name`,
    Segment,
    Country,
    City,
    State,
    `Postal Code`,
    Region,
    `Product ID`,
    Category,
    `Sub-Category`,
    `Product Name`,
    CAST(TRIM(REPLACE(Sales, ',', '')) AS DECIMAL(10,2))
FROM train;
SELECT COUNT(*) FROM raw_data;
SELECT sales FROM raw_data LIMIT 10;

CREATE TABLE customers(
	customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    region VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE products(
	product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE orders(
	order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE sales(
	sale_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    sales_amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers
SELECT
	MAX(customer_id),
    MAX(customer_name),
    MAX(segment),
    MAX(region),
    MAX(city),
    MAX(state)
FROM raw_data
GROUP BY customer_id;

INSERT INTO products
SELECT
	product_id,
    MAX(product_name),
    MAX(category),
    MAX(sub_category)
FROM raw_data
GROUP BY product_id;

INSERT INTO orders
SELECT
	order_id,
    MAX(order_date),
    MAX(ship_date),
    MAX(ship_mode),
    MAX(customer_id)
FROM raw_data
GROUP BY order_id;

INSERT INTO sales(order_id, product_id, sales_amount)
SELECT
	order_id,
    product_id, 
    sales
FROM raw_data;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM sales;

SELECT SUM(sales_amount) AS total_revenue FROM sales;

SELECT c.region, SUM(s.sales_amount) AS revenue
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region;

SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(s.sales_amount) AS REVENUE
FROM orders o
JOIN sales s ON o.order_id = s.order_id
GROUP BY month;

SELECT c.customer_name, SUM(s.sales_amount) AS total_spent
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

SELECT p.category, SUM(s.sales_amount) AS revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category;