-- What is the date of the earliest and latest order, returned in one query?
SELECT
  MIN(purchase_ts) AS earliest_date,
  MAX(purchase_ts) AS latest_date
FROM core.orders;

-- What is the average order value for purchases made in USD? What about average order value for purchases made in USD in 2019?
SELECT
  avg(usd_price) AS AOV
FROM core.orders
WHERE purchase_ts >= DATE '2019-01-01' 
AND purchase_ts < DATE '2020-01-01';

-- Return the id, loyalty program status, and account creation date for customers who made an account on desktop or mobile. Rename the columns to more descriptive names.
SELECT
  id AS Customer_Id, 
  loyalty_program AS Loyalty_Program_Status,
  created_on AS Account_Creation_Date
FROM core.customers
WHERE account_creation_method IN ('desktop', 'mobile');

-- What are all the unique products that were sold in AUD on website, sorted alphabetically?

SELECT
  DISTINCT(product_name) as Product_Name
FROM core.orders
WHERE currency = 'AUD'
AND purchase_platform = 'website'
ORDER BY Product_Name ASC;

-- What are the first 10 countries in the North American region, sorted in descending alphabetical order?

SELECT
  country_code AS Country
FROM core.geo_lookup
WHERE region = 'NA'
ORDER BY country_code DESC
LIMIT 10;
--------------------------------------


-- What is the total number of orders by shipping month, sorted from most recent to oldest?

SELECT
  COUNT(DISTINCT(order_id)) AS Total_orders,
  EXTRACT(MONTH from ship_ts) AS Shipping_month
FROM core.order_status
GROUP BY EXTRACT(MONTH from ship_ts)
ORDER BY EXTRACT(MONTH from ship_ts) DESC;

-- What is the average order value by year? Can you round the results to 2 decimals?

SELECT
  ROUND(AVG(usd_price),2) AS AOV,
  EXTRACT(YEAR FROM purchase_ts) AS Year
FROM core.orders
GROUP BY EXTRACT(YEAR FROM purchase_ts);

-- Create a helper column `is_refund`  in the `order_status`  table that returns 1 if there is a refund, 0 if not. Return the first 20 records.

SELECT
  CASE WHEN
    refund_ts IS NOT NULL THEN 1 --if there is any refund value at all, then refund status is 1.
  ELSE 0
  END AS is_refund
FROM core.order_status
LIMIT 20;

-- Return the product IDs and product names of all Apple products.

SELECT Distinct
  product_id,
  product_name
FROM core.orders
WHERE product_name LIKE '%Apple%';

-- Calculate the time to ship in days for each order and return all original columns from the table.

WITH Ship_Time AS (
  SELECT
    order_id,
    DATE_DIFF(purchase_ts, ship_ts, DAY) AS Ship_Time
  FROM core.order_status
)

SELECT
  *
FROM core.order_status a
LEFT JOIN Ship_Time b ON a.order_id = b.order_id


