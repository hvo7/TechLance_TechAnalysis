-- What is the date of the earliest and latest order?
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
-- WHERE EXTRACT(YEAR FROM purchase_ts) = 2019

-- Return the id, loyalty program status, and account creation date for customers who made an account on desktop or mobile. Rename the columns to more descriptive names.
SELECT
  id AS Customer_Id, 
  loyalty_program AS Loyalty_Program_Status,
  created_on AS Account_Creation_Date
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
  country_code AS Country
FROM core.geo_lookup
WHERE region = 'NA'
ORDER BY 1 DESC
LIMIT 10;

--------------------------------------

-- What is the total number of orders by shipping month, sorted from most recent to oldest?

SELECT
  DATE_TRUNC(ship_ts, month) AS Shipping_month,
  COUNT(DISTINCT(order_id)) AS Total_orders  
FROM core.order_status
GROUP BY 1
ORDER BY 1 DESC;

-- What is the average order value by year? Can you round the results to 2 decimals?

SELECT
  EXTRACT(YEAR FROM purchase_ts) AS Year,
  ROUND(AVG(usd_price),2) AS AOV
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
  DATE_DIFF(ship_ts, purchase_ts, DAY) AS Time_to_ship
FROM core.order_status;

--------------------

-- What is the refund rate per year, expressed as a percent (i.e. 0.0445 should be shown as 44.5)? Can you round this to 2 decimals? 

SELECT
  EXTRACT(Year FROM purchase_ts) AS Year,
  ROUND(AVG(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END)*100,2) AS Refund_Rate
FROM core.order_status
GROUP BY 1
ORDER BY 1;

-- What is the total number of orders per year for each product? Clean up product names when grouping and return in alphabetical order after sorting by months. 

SELECT
  DATE_TRUNC(purchase_ts, Month) AS Month,
    CASE WHEN product_name = '27in"" 4k gaming monitor' 
      THEN '27in 4K gaming monitor' 
      ELSE product_name 
    END AS Cleaned_product_name,
  COUNT(DISTINCT(id)) AS Order_Count
FROM core.orders
GROUP BY 1,2
ORDER BY 1,2;

-- What is the average order value per year for products that are either laptops or headphones? Round this to 2 decimals.

SELECT DISTINCT(product_name) FROM core.orders;

SELECT
  EXTRACT(YEAR FROM purchase_ts) AS Year,
  ROUND(AVG(usd_price),2) AS AOV
FROM core.orders
WHERE LOWER(product_name) LIKE '%headphones%'
OR LOWER(product_name) LIKE '%laptop%'
-- WHERE product_name IN ('Apple Airpods Headphones', 'ThinkPad Laptop', 'Macbook Air Laptop', 'bose soundsport headphones' )
GROUP BY 1
ORDER BY 1