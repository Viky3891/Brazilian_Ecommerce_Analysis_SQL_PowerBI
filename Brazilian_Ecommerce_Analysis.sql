CREATE DATABASE brazilian_ecommerce_db;
USE brazilian_ecommerce_db;

-- 1) Total orders
SELECT 
    COUNT(DISTINCT order_id)
FROM
    brazilian_ecommerce_db.olist_orders_dataset;
-- About 99K orders in total.

-- 2) Total unique customers
SELECT 
    COUNT(DISTINCT customer_unique_id)
FROM
    brazilian_ecommerce_db.olist_customers_dataset;
-- About 96K unique customers.

-- 3) Total sales
SELECT 
    SUM(price) AS total_sales
FROM
    brazilian_ecommerce_db.olist_order_items_dataset;
--  Total sales are about 13.6M.
    
-- 4) Average sales per order 
SELECT 
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)
FROM
    brazilian_ecommerce_db.olist_order_items_dataset; 
-- Average order value is about 137.75.

-- 5) Orders by status
SELECT 
    order_status, COUNT(*)
FROM
    brazilian_ecommerce_db.olist_orders_dataset
GROUP BY order_status
ORDER BY COUNT(*) DESC;
-- Most orders (97%) are delivered.

-- 6) Top 10 cities by customers
SELECT 
    customer_city, COUNT(DISTINCT customer_unique_id)
FROM
    brazilian_ecommerce_db.olist_customers_dataset
GROUP BY customer_city
ORDER BY COUNT(DISTINCT customer_unique_id) DESC
LIMIT 10;
-- Sao Paulo has the most customers.

-- 7) Top 5 states by customers
SELECT 
    customer_state, COUNT(DISTINCT customer_unique_id)
FROM
    brazilian_ecommerce_db.olist_customers_dataset
GROUP BY customer_state
ORDER BY COUNT(DISTINCT customer_unique_id) DESC
LIMIT 5;
-- SP has the most customers.

-- 8) Lowest customer state
SELECT 
    customer_state, COUNT(DISTINCT customer_unique_id)
FROM
    brazilian_ecommerce_db.olist_customers_dataset
GROUP BY customer_state
ORDER BY COUNT(DISTINCT customer_unique_id) ASC
LIMIT 1;
-- RR has the fewest customers.

-- 9) States with more than 1,000 customers
SELECT 
    customer_state, COUNT(DISTINCT customer_unique_id)
FROM
    brazilian_ecommerce_db.olist_customers_dataset
GROUP BY customer_state
HAVING COUNT(DISTINCT customer_unique_id) > 1000;
-- Only a few states have 1,000+ customers.

-- 10) Sales by payment type
SELECT 
    payment_type, SUM(payment_value)
FROM
    brazilian_ecommerce_db.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY SUM(payment_value) DESC;
-- Credit card brings the most sales.

-- 11) Average sales by payment type
SELECT 
    payment_type, ROUND(AVG(payment_value), 2)
FROM
    brazilian_ecommerce_db.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY ROUND(AVG(payment_value), 2) DESC;
-- Credit card has the highest average payment.

-- 12) Reviews count by score.
SELECT 
    review_score, COUNT(DISTINCT review_id) AS reviews_count
FROM
    brazilian_ecommerce_db.olist_order_reviews_dataset
GROUP BY review_score
ORDER BY reviews_count DESC;
-- Most reviews are 5 stars.

-- 13) Average review score
SELECT 
    ROUND(AVG(review_score), 2)
FROM
    brazilian_ecommerce_db.olist_order_reviews_dataset;
-- Average review score is about 4.1.

-- 14) Total delivered orders
SELECT 
    COUNT(*)
FROM
    brazilian_ecommerce_db.olist_orders_dataset
WHERE
    order_status = 'delivered';
-- About 96.5K orders are delivered.

-- 15) Orders with missing delivery date
SELECT 
    COUNT(*)
FROM
    brazilian_ecommerce_db.olist_orders_dataset
WHERE
    order_delivered_customer_date IS NULL
        OR order_delivered_customer_date = '';
--  About 3K orders have no delivery date.

-- 16) Orders with more than one review
SELECT 
    order_id, COUNT(*) AS review_count
FROM
    brazilian_ecommerce_db.olist_order_reviews_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;
-- Some orders have more than one review.

-- 17) Replace missing review comments with "No Comment"
SELECT 
    review_id,
    IFNULL(NULLIF(review_comment_message, ''),
            'No Comment') AS review_comment
FROM
    brazilian_ecommerce_db.olist_order_reviews_dataset
LIMIT 10;
-- Most reviews have no comment.

-- 18) Average delivery days
SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)),
            2)
FROM
    brazilian_ecommerce_db.olist_orders_dataset
WHERE
    order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND order_delivered_customer_date != '';
-- Delivery takes about 12 days on average.

-- 19) On-time vs late orders.
SELECT 
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'ON TIME'
        ELSE 'LATE'
    END AS delivery_status,
    COUNT(*) AS orders
FROM
    brazilian_ecommerce_db.olist_orders_dataset
WHERE
    order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND order_delivered_customer_date != ''
GROUP BY delivery_status;
-- About 8% of orders arrive late.

-- 20) Customers from SP, RJ and MG
SELECT 
    COUNT(DISTINCT customer_unique_id)
FROM
    brazilian_ecommerce_db.olist_customers_dataset
WHERE
    customer_state IN ('SP' , 'RJ', 'MG');
-- SP, RJ and MG have most of the customers.

-- 21) Orders by customer state
SELECT 
    c.customer_state, COUNT(*) AS Orders
FROM
    brazilian_ecommerce_db.olist_orders_dataset AS o
        JOIN
    brazilian_ecommerce_db.olist_customers_dataset AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Orders DESC;
-- SP places the most orders.

-- 22) Sales by customer state
SELECT 
    c.customer_state, SUM(price) AS sales
FROM
    brazilian_ecommerce_db.olist_order_items_dataset AS i
        JOIN
    brazilian_ecommerce_db.olist_orders_dataset AS o ON i.order_id = o.order_id
        JOIN
    brazilian_ecommerce_db.olist_customers_dataset AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY sales DESC;
-- SP has the highest sales.

-- 23) Average review score by order status
SELECT 
    o.order_status, ROUND(AVG(review_score), 2) AS avg_review
FROM
    brazilian_ecommerce_db.olist_order_reviews_dataset AS r
        JOIN
    brazilian_ecommerce_db.olist_orders_dataset AS o ON r.order_id = o.order_id
GROUP BY o.order_status
ORDER BY avg_review DESC;
-- Delivered orders get higher review scores.

-- 24) Orders with no review
SELECT 
    COUNT(*) AS orders
FROM
    brazilian_ecommerce_db.olist_orders_dataset AS o
        LEFT JOIN
    brazilian_ecommerce_db.olist_order_reviews_dataset AS r ON r.order_id = o.order_id
WHERE
    r.review_id IS NULL;
-- Very few orders have no review.
 
 -- 25) Payments above average
 SELECT 
    COUNT(*) AS payment_above_avg
FROM
    brazilian_ecommerce_db.olist_order_payments_dataset
WHERE
    payment_value > (SELECT 
            AVG(payment_value)
        FROM
            brazilian_ecommerce_db.olist_order_payments_dataset);
-- Most payments are below the average.
 
 -- 26) Top 5 states by sales
 WITH state_sales AS (
  SELECT c.customer_state, ROUND(SUM(i.price), 2) AS sales
  FROM brazilian_ecommerce_db.olist_order_items_dataset i
  JOIN brazilian_ecommerce_db.olist_orders_dataset o
    ON i.order_id = o.order_id
  JOIN brazilian_ecommerce_db.olist_customers_dataset c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_state
)
SELECT customer_state, sales
FROM state_sales
ORDER BY sales DESC
LIMIT 5;
-- Top 5 states bring most of the sales.
 
 -- 27) Customers with more than one order
 WITH customer_orders AS(SELECT customer_unique_id,count(*) AS orders 
 FROM brazilian_ecommerce_db.olist_customers_dataset AS c
 JOIN brazilian_ecommerce_db.olist_orders_dataset AS o
 ON c.customer_id=o.customer_id
 GROUP BY c.customer_unique_id)
 SELECT COUNT(*) AS repeated_customer
 FROM customer_orders
 WHERE orders>1;
 -- Only about 3% of customers ordered again.
 
 -- 28) Monthly orders vs previous month
 WITH monthly AS (
  SELECT LEFT(order_purchase_timestamp, 7) AS month,
         COUNT(*) AS orders
  FROM brazilian_ecommerce_db.olist_orders_dataset
  GROUP BY LEFT(order_purchase_timestamp, 7)
)
SELECT month, orders,
       LAG(orders) OVER (ORDER BY month) AS prev_month_orders
FROM monthly
ORDER BY month;
-- Orders grew over time and peaked in Nov 2017.

-- 29) Rank states by sales
WITH state_sales AS (
  SELECT c.customer_state, ROUND(SUM(i.price), 2) AS sales
  FROM brazilian_ecommerce_db.olist_order_items_dataset i
  JOIN brazilian_ecommerce_db.olist_orders_dataset o
    ON i.order_id = o.order_id
  JOIN brazilian_ecommerce_db.olist_customers_dataset c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_state
)
SELECT customer_state, sales,
       RANK() OVER (ORDER BY sales DESC) AS sales_rank
FROM state_sales
ORDER BY sales_rank;
-- SP ranks first in sales.

-- 30) View for delivered orders
CREATE VIEW brazilian_ecommerce_db.delivered_orders AS
    SELECT 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM
        brazilian_ecommerce_db.olist_orders_dataset
    WHERE
        order_status = 'delivered';

SELECT 
    COUNT(*)
FROM
    brazilian_ecommerce_db.delivered_orders;
-- The view gives clean delivered order data.