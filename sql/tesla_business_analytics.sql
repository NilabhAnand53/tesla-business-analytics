-- Run CREATE DATABASE separately, connect to tesla_db, then update the CSV paths and run the remaining sections.
CREATE DATABASE tesla_db;



-- 1. Table Creation

-- Q1. Create a customers table with customer details such as customer ID, name, email, location, signup date, and membership tier.
CREATE TABLE customers (
    customer_id       VARCHAR(20) PRIMARY KEY,
    customer_name     VARCHAR(100),
    email             VARCHAR(150),
    city              VARCHAR(100),
    state_or_region   VARCHAR(100),
    country           VARCHAR(100),
    signup_date       DATE,
    membership_tier   VARCHAR(50),
    email_missing     BOOLEAN
);

-- Q2. Create an orders table to store customer orders, product details, quantity, price, order status, and payment method.
CREATE TABLE orders (
    order_id          VARCHAR(20) PRIMARY KEY,
    customer_id       VARCHAR(20) REFERENCES customers(customer_id),
    order_date        DATE,
    product_category  VARCHAR(100),
    quantity          INTEGER,
    unit_price_usd    NUMERIC(14,2),
    order_status      VARCHAR(50),
    payment_method    VARCHAR(50)
);

-- Q3. Create a revenue table to store payment and refund information for each order.
CREATE TABLE revenue (
    revenue_id          VARCHAR(20) PRIMARY KEY,
    order_id            VARCHAR(20) REFERENCES orders(order_id),
    payment_date        DATE,
    amount_paid_usd     NUMERIC(14,2),
    payment_status      VARCHAR(50),
    refund_amount_usd   NUMERIC(14,2)
);


COPY public.customers (
    customer_id, customer_name, email, city, state_or_region,
    country, signup_date, membership_tier, email_missing
)
FROM 'D:/kasala/cleaned/customers_cleaned.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY public.orders (
    order_id, customer_id, order_date, product_category,
    quantity, unit_price_usd, order_status, payment_method
)
FROM 'D:/kasala/cleaned/orders_cleaned.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY public.revenue (
    revenue_id, order_id, payment_date, amount_paid_usd,
    payment_status, refund_amount_usd
)
FROM 'D:/kasala/cleaned/revenue_cleaned.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Q4. Display all records from the customers table.
SELECT *
FROM customers;

-- 2. Database Check

-- Q5. Display all databases that are not PostgreSQL template databases.
SELECT datname
FROM pg_database
WHERE datistemplate = false;

-- Q6. Display all tables present inside the public schema.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Q7. Display the structure of the customers table.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customers'
ORDER BY ordinal_position;

-- Q8. Display the structure of the orders table.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'orders'
ORDER BY ordinal_position;

-- Q9. Display the structure of the revenue table.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'revenue'
ORDER BY ordinal_position;

-- 3. Data Preview

-- Q10. Display the first 10 records from the customers table.
SELECT *
FROM customers
ORDER BY customer_id
LIMIT 10;

-- Q11. Display the first 10 records from the orders table.
SELECT *
FROM orders
ORDER BY order_id
LIMIT 10;

-- Q12. Display the first 10 records from the revenue table.
SELECT *
FROM revenue
ORDER BY revenue_id
LIMIT 10;

-- 4. Record Counts

-- Q13. Find the total number of customers.
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q14. Find the total number of orders.
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q15. Find the total number of payment records.
SELECT COUNT(*) AS total_payments
FROM revenue;

-- 5. NULL Check

-- Q16. Find all customers whose email is missing.
SELECT *
FROM customers
WHERE email IS NULL;

-- Q17. Find all orders whose unit price is missing.
SELECT *
FROM orders
WHERE unit_price_usd IS NULL;

-- Q18. Find all revenue records where the payment amount is missing.
SELECT *
FROM revenue
WHERE amount_paid_usd IS NULL;

-- 6. Basic Analysis

-- Q19. Display all unique countries of customers.
SELECT DISTINCT country
FROM customers;

-- Q20. Display all unique states or regions.
SELECT DISTINCT state_or_region
FROM customers;

-- Q21. Display all unique cities.
SELECT DISTINCT city
FROM customers;

-- Q22. Display all unique membership tiers.
SELECT DISTINCT membership_tier
FROM customers;

-- Q23. Display all unique product categories.
SELECT DISTINCT product_category
FROM orders;

-- Q24. Display all unique payment methods.
SELECT DISTINCT payment_method
FROM orders;

-- Q25. Display all unique order statuses.
SELECT DISTINCT order_status
FROM orders;

-- Q26. Display all unique payment statuses.
SELECT DISTINCT payment_status
FROM revenue;

-- 7. Aggregate Functions

-- Q27. Find the minimum, maximum, and average unit price of orders.
SELECT
    MIN(unit_price_usd) AS minimum_price,
    MAX(unit_price_usd) AS maximum_price,
    AVG(unit_price_usd) AS average_price
FROM orders;

-- Q28. Find the total revenue generated.
SELECT
    SUM(amount_paid_usd) AS total_revenue
FROM revenue;

-- Q29. Find the average quantity per order.
SELECT
    AVG(quantity) AS average_quantity
FROM orders;

-- 8. GROUP BY

-- Q30. Find the number of customers in each country and display the highest customer count first.
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC;

-- Q31. Find the number of customers in each membership tier.
SELECT
    membership_tier,
    COUNT(*) AS total_customers
FROM customers
GROUP BY membership_tier
ORDER BY total_customers DESC;

-- Q32. Find the number of orders for each product category.
SELECT
    product_category,
    COUNT(*) AS total_orders
FROM orders
GROUP BY product_category
ORDER BY total_orders DESC;

-- Q33. Find the number of orders for each payment method.
SELECT
    payment_method,
    COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Q34. Find the number of transactions for each payment status.
SELECT
    payment_status,
    COUNT(*) AS total_transactions
FROM revenue
GROUP BY payment_status;

-- 9. INNER JOIN

-- Q35. Display order details along with the customer's name, country, and city.
SELECT
    o.order_id,
    c.customer_name,
    c.country,
    c.city,
    o.product_category,
    o.quantity,
    o.unit_price_usd
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;

-- Q36. Display order details along with the amount paid and payment status.
SELECT
    o.order_id,
    o.product_category,
    r.amount_paid_usd,
    r.payment_status
FROM orders o
INNER JOIN revenue r
ON o.order_id = r.order_id;

-- 10. THREE TABLE JOIN

-- Q37. Combine customers, orders, and revenue information to create a complete transaction view.
SELECT
    o.order_id,
    c.customer_name,
    c.country,
    c.city,
    o.product_category,
    o.quantity,
    o.unit_price_usd,
    r.amount_paid_usd,
    r.payment_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN revenue r
ON o.order_id = r.order_id;

-- 11. BUSINESS QUESTIONS

-- Q38. Find the top 10 customers based on the number of orders.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC, c.customer_id
LIMIT 10;

-- Q39. Find the total revenue generated by each country.
SELECT
    c.country,
    SUM(r.amount_paid_usd) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN revenue r
ON o.order_id = r.order_id
GROUP BY c.country
ORDER BY revenue DESC;

-- Q40. Find the total revenue generated by each state or region.
SELECT
    c.state_or_region,
    SUM(r.amount_paid_usd) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN revenue r
ON o.order_id = r.order_id
GROUP BY c.state_or_region
ORDER BY revenue DESC;

-- Q41. Find the total revenue generated by each membership tier.
SELECT
    c.membership_tier,
    SUM(r.amount_paid_usd) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN revenue r
ON o.order_id = r.order_id
GROUP BY c.membership_tier
ORDER BY revenue DESC;

-- Q42. Find the total revenue generated by each product category.
SELECT
    o.product_category,
    SUM(r.amount_paid_usd) AS revenue
FROM orders o
JOIN revenue r
ON o.order_id = r.order_id
GROUP BY o.product_category
ORDER BY revenue DESC;

-- Q43. Find the total quantity sold for each product category.
SELECT
    product_category,
    SUM(quantity) AS total_quantity
FROM orders
GROUP BY product_category
ORDER BY total_quantity DESC;

-- 12. HAVING

-- Q44. Find countries having more than 50 customers.
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country
HAVING COUNT(*) > 50;

-- Q45. Find product categories having more than 100 units sold.
SELECT
    product_category,
    SUM(quantity) AS total_quantity
FROM orders
GROUP BY product_category
HAVING SUM(quantity) > 100;

-- 13. CASE WHEN

-- Q46. Convert membership tiers into customer segments:
-- Gold → Premium, Silver → Regular, and everything else → Basic.
-- Illustrative rule from the document. Gold/Silver may not occur in
-- this dataset; unmatched tiers will be labelled Basic by this exercise.
SELECT
    customer_name,
    membership_tier,
    CASE
        WHEN membership_tier = 'Gold' THEN 'Premium'
        WHEN membership_tier = 'Silver' THEN 'Regular'
        ELSE 'Basic'
    END AS customer_segment
FROM customers;

-- Q47. Classify products based on their unit price:
-- 100,000+ → Luxury, 50,000–99,999 → Mid Range, below 50,000 → Entry Level.
-- These are exercise thresholds, not validated business segments.
SELECT
    product_category,
    unit_price_usd,
    CASE
        WHEN unit_price_usd >= 100000 THEN 'Luxury'
        WHEN unit_price_usd >= 50000 THEN 'Mid Range'
        ELSE 'Entry Level'
    END AS price_segment
FROM orders;

-- 14. SUBQUERY

-- Q48. Find all orders whose unit price is greater than the overall average unit price.
SELECT *
FROM orders
WHERE unit_price_usd >
(
    SELECT AVG(unit_price_usd)
    FROM orders
);

-- Q49. Find all revenue transactions whose payment amount is greater than the average payment amount.
SELECT *
FROM revenue
WHERE amount_paid_usd >
(
    SELECT AVG(amount_paid_usd)
    FROM revenue
);

-- 15. CTE

-- Q50. Calculate the total revenue generated by each customer and display them from highest to lowest revenue.
WITH customer_revenue AS
(
    SELECT
        o.customer_id,
        SUM(r.amount_paid_usd) AS revenue
    FROM orders o
    JOIN revenue r
    ON o.order_id = r.order_id
    GROUP BY o.customer_id
)
SELECT *
FROM customer_revenue
ORDER BY revenue DESC;

-- 16. WINDOW FUNCTIONS

-- Q51. Rank product categories based on their total quantity sold.
SELECT
    product_category,
    SUM(quantity) AS quantity_sold,
    RANK() OVER (
        ORDER BY SUM(quantity) DESC
    ) AS category_rank
FROM orders
GROUP BY product_category;

-- Q52. Calculate total revenue for each customer and assign a gap-free rank based on revenue.
SELECT
    customer_id,
    SUM(amount_paid_usd) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(amount_paid_usd) DESC
    ) AS revenue_rank
FROM orders o
JOIN revenue r
ON o.order_id = r.order_id
GROUP BY customer_id;

-- 17. ROW_NUMBER

-- Q53. Assign a sequential number to customers within each country.
SELECT
    customer_name,
    country,
    ROW_NUMBER() OVER (
        PARTITION BY country
        ORDER BY customer_name, customer_id
    ) AS row_num
FROM customers;

-- 18. VIEW

-- Q54. Create a reusable view that combines customer, order, and revenue information.
-- This view is at payment-join grain. Repeated order quantities must
-- not be summed as though each row represented a different order.
CREATE OR REPLACE VIEW customer_sales AS
SELECT
    c.customer_name,
    c.country,
    c.city,
    o.product_category,
    o.quantity,
    r.amount_paid_usd
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN revenue r
ON o.order_id = r.order_id;

-- Q55. Display all records from the customer_sales view.
SELECT *
FROM customer_sales;

-- 19. FINAL KPIs

-- Q56. Find the total number of customers.
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q57. Find the total number of orders.
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q58. Find the total revenue.
SELECT SUM(amount_paid_usd) AS total_revenue
FROM revenue;

-- Q59. Find the total refund amount.
SELECT SUM(refund_amount_usd) AS total_refund
FROM revenue;

-- Q60. Find the average transaction value.
SELECT AVG(amount_paid_usd) AS average_transaction
FROM revenue;

-- Q61. Find the highest transaction value.
SELECT MAX(amount_paid_usd) AS highest_transaction
FROM revenue;

-- Q62. Find the lowest transaction value.
SELECT MIN(amount_paid_usd) AS lowest_transaction
FROM revenue;

