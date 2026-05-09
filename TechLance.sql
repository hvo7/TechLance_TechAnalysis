-- What is the date of the earliest and latest order?
SELECT
  MIN(purchase_ts) AS earliest_date,
  MAX(purchase_ts) AS latest_date
FROM core.orders;

-- What is the average order value for purchases made in USD? What about average order value for purchases made in USD in 2019?
SELECT
  avg(usd_price) AS aov
FROM core.orders
WHERE purchase_ts >= DATE '2019-01-01' 
AND purchase_ts < DATE '2020-01-01';
-- WHERE EXTRACT(YEAR FROM purchase_ts) = 2019

-- Return the id, loyalty program status, and account creation date for customers who made an account on desktop or mobile. Rename the columns to more descriptive names.
SELECT
  id AS customer_Id, 
  loyalty_program AS loyalty_Program_Status,
  created_on AS account_Creation_Date
FROM core.customers
WHERE account_creation_method IN ('desktop', 'mobile');

-- What are all the unique products that were sold in AUD on website, sorted alphabetically?

SELECT
  DISTINCT(product_name)
FROM core.orders
WHERE currency = 'AUD'
AND purchase_platform = 'website'
ORDER BY 1 ASC;

-- What are the first 10 countries in the North American region, sorted in descending alphabetical order?

SELECT
  country_code AS country
FROM core.geo_lookup
WHERE region = 'NA'
ORDER BY 1 DESC
LIMIT 10;

--------------------------------------

-- What is the total number of orders by shipping month, sorted from most recent to oldest?

SELECT
  DATE_TRUNC(ship_ts, month) AS shipping_month,
  COUNT(DISTINCT(order_id)) AS total_orders  
FROM core.order_status
GROUP BY 1
ORDER BY 1 DESC;

-- What is the average order value by year? Can you round the results to 2 decimals?

SELECT
  EXTRACT(YEAR FROM purchase_ts) AS year,
  ROUND(AVG(usd_price),2) AS aov
FROM core.orders
GROUP BY 1
ORDER BY 1;

-- Create a helper column `is_refund`  in the `order_status`  table that returns 1 if there is a refund, 0 if not. Return the first 20 records.

SELECT
  *,
  CASE WHEN
  refund_ts IS NOT NULL THEN 1   ELSE 0 END AS is_refund --if there is any refund value at all, then refund status is 1.
FROM core.order_status
LIMIT 20;

-- Return the product IDs and product names of all Apple products.

SELECT Distinct
  product_id,
  product_name
FROM core.orders
WHERE product_name LIKE '%Apple%'
OR product_name LIKE '%Macbook%';

-- Calculate the time to ship in days for each order and return all original columns from the table.

SELECT
  *,
  DATE_DIFF(ship_ts, purchase_ts, DAY) AS time_to_ship
FROM core.order_status;

--------------------

-- What is the refund rate per year, expressed as a percent (i.e. 0.0445 should be shown as 44.5)? Can you round this to 2 decimals? 

SELECT
  EXTRACT(Year FROM purchase_ts) AS year,
  ROUND(AVG(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END)*100,2) AS refund_Rate
FROM core.order_status
GROUP BY 1
ORDER BY 1;

-- What is the total number of orders per year for each product? Clean up product names when grouping and return in alphabetical order after sorting by months. 

SELECT
  DATE_TRUNC(purchase_ts, Month) AS month,
    CASE WHEN product_name = '27in"" 4k gaming monitor' 
      THEN '27in 4K gaming monitor' 
      ELSE product_name 
    END AS cleaned_product_name,
  COUNT(DISTINCT(id)) AS order_Count
FROM core.orders
GROUP BY 1,2
ORDER BY 1,2;

-- What is the average order value per year for products that are either laptops or headphones? Round this to 2 decimals.

SELECT DISTINCT(product_name) FROM core.orders;

SELECT
  EXTRACT(YEAR FROM purchase_ts) AS year,
  ROUND(AVG(usd_price),2) AS aov
FROM core.orders
WHERE LOWER(product_name) LIKE '%headphones%'
OR LOWER(product_name) LIKE '%laptop%'
-- WHERE product_name IN ('Apple Airpods Headphones', 'ThinkPad Laptop', 'Macbook Air Laptop', 'bose soundsport headphones' )
GROUP BY 1
ORDER BY 1;

--------------------------------------------

-- What were the order counts, sales, and AOV for Macbooks sold in North America for each quarter across all years? 

-- What is the average quarterly order count and total sales for Macbooks sold in North America? (i.e. “For North America Macbooks, average of X units sold per quarter and Y in dollar sales per quarter”)

WITH quarterly_metrics AS (
  SELECT
    DATE_TRUNC(orders.purchase_ts, quarter) AS quarter,
    COUNT(DISTINCT(orders.id)) AS order_count,
    ROUND(SUM(orders.usd_price),2) AS total_sales,
    ROUND(AVG(orders.usd_price),2) AS aov
  FROM core.orders
  LEFT JOIN core.customers 
    ON orders.customer_id = customers.id
  LEFT JOIN core.geo_lookup
    ON customers.country_code = geo_lookup.country_code
  WHERE LOWER(product_name) LIKE '%macbook%'
  AND region = 'NA'
  GROUP BY 1
  ORDER BY 1 DESC -- Sort from most recent to earliest
)

SELECT
  AVG(order_count) AS avg_order_count,
  AVG(total_sales),2  AS total_sales
FROM quarterly_metrics;

-- For products purchased in 2022 on the website or products purchased on mobile in any year, which region has the average highest time to deliver? 

SELECT DISTINCT(purchase_platform) FROM core.orders;

SELECT
  geo_lookup.region,
  ROUND(AVG(DATE_DIFF(order_status.delivery_ts, order_status.purchase_ts, DAY)),2) AS days_to_deliver
FROM core.order_status
LEFT JOIN core.orders
  ON orders.id = order_status.order_id
LEFT JOIN core.customers
  ON orders.customer_id = customers.id
LEFT JOIN core.geo_lookup
  ON customers.country_code = geo_lookup.country_code
WHERE (EXTRACT(YEAR FROM order_status.purchase_ts) = 2022 AND orders.purchase_platform = 'website') 
OR (orders.purchase_platform = 'mobile app')
GROUP BY 1
ORDER BY 2 DESC;

-- For website purchases made in 2022 or Samsung purchases made in 2021, express time to deliver in weeks instead of days.

SELECT DISTINCT(product_name) FROM core.orders;

SELECT
  geo_lookup.region,
  ROUND(AVG(DATE_DIFF(order_status.delivery_ts, order_status.purchase_ts, WEEK)),2) AS days_to_deliver
FROM core.order_status
LEFT JOIN core.orders
  ON orders.id = order_status.order_id
LEFT JOIN core.customers
  ON orders.customer_id = customers.id
LEFT JOIN core.geo_lookup
  ON customers.country_code = geo_lookup.country_code
WHERE (EXTRACT(YEAR FROM order_status.purchase_ts) = 2022 AND orders.purchase_platform = 'website') 
OR (EXTRACT(YEAR FROM order_status.purchase_ts) = 2021 AND LOWER(product_name) LIKE '%samsung%')
GROUP BY 1
ORDER BY 2 DESC;

-- What was the refund rate and refund count for each product overall? 

SELECT
  CASE WHEN product_name = '27in"" 4k gaming monitor' 
    THEN '27in 4K gaming monitor' 
    ELSE product_name
    END AS cleaned_product_name, -- Clean the 27in 4k monitor, so it aggregates correctly
  ROUND(AVG(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END),2) AS refund_rate,
  COUNT(refund_ts) AS refund_count
FROM core.orders
LEFT JOIN core.order_status
  ON orders.id = order_status.order_id
GROUP BY 1
ORDER BY 3 DESC;

-- What was the refund rate and refund count for each product per year? How would you interpret these rates in English?
SELECT
  EXTRACT(YEAR FROM orders.purchase_ts) AS year,
  CASE WHEN product_name = '27in"" 4k gaming monitor' 
    THEN '27in 4K gaming monitor' 
    ELSE product_name
    END AS cleaned_product_name,
  ROUND(AVG(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END),2) AS refund_rate,
  COUNT(refund_ts) AS refund_count
FROM core.orders
LEFT JOIN core.order_status
  ON orders.id = order_status.order_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

/* Example: This query looks at each particular year and displays the highest refund rates for each product for orders during the specific year period. Foe example, for all order of 2019, 
 the Macbook Air Laptop had the highest refund rate. But for 2021, the ThinkPad Laptop was the most refunded product during the 2021 time period.
*/


-- Within each region, what is the most popular product? 
 
-- Clarify what is considered "popular" - Make the assumption it is highest order count, since a very expensive product may have highest revenue and aov, but not too many orders

WITH product_count_per_region AS (
  SELECT
    geo_lookup.region,
    CASE WHEN orders.product_name = '27in"" 4k gaming monito' 
      THEN '27in 4K gaming monitor' 
      ELSE orders.product_name
      END AS clean_product_name,
    COUNT(DISTINCT(orders.id)) AS order_count,
    ROW_NUMBER() OVER (
      PARTITION BY region 
      ORDER BY COUNT(DISTINCT(orders.id)) DESC
      ) AS row_num
  FROM core.orders
  LEFT JOIN core.customers
    ON orders.customer_id = customers.id
  LEFT JOIN core.geo_lookup
    ON customers.country_code = geo_lookup.country_code
  GROUP BY 1, 2
  ORDER BY 1, 2
)

SELECT
  region,
  clean_product_name,
  order_count
FROM product_count_per_region
WHERE row_num = 1;


-- How does the time to make a purchase differ between loyalty customers vs. non-loyalty customers? 

-- Should we have time as days or months ? -> Showcase both
SELECT
  customers.loyalty_program,
  ROUND(AVG(DATE_DIFF(orders.purchase_ts, customers.created_on, DAY)),1) AS days_to_purchase,
  ROUND(AVG(DATE_DIFF(orders.purchase_ts, customers.created_on, MONTH)),1) AS days_to_purchase
FROM core.customers
LEFT JOIN core.orders
  ON customers.id = orders.customer_id
GROUP BY 1;

-- What is the time to purchase per loyalty program, per purchase platform. Return the number of records to benchmark the severity of nulls.

SELECT
  customers.loyalty_program,
  orders.purchase_platform,
  ROUND(AVG(DATE_DIFF(orders.purchase_ts, customers.created_on, DAY)),1) AS days_to_purchase,
  ROUND(AVG(DATE_DIFF(orders.purchase_ts, customers.created_on, MONTH)),1) AS days_to_purchase,
  COUNT(*) as row_count
FROM core.customers
LEFT JOIN core.orders
  ON customers.id = orders.customer_id
GROUP BY 1,2


