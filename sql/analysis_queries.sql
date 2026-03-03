/* ============================================================
   CUSTOMER & SALES ANALYSIS
   Description:
   SQL queries used to generate business insights from sales and
   customer datasets (single source of truth).
   ============================================================ */

---------------------------------------------------------------
-- 0) QUICK DATA CHECKS 
---------------------------------------------------------------

-- Preview data
SELECT * FROM sales_data LIMIT 10;
SELECT * FROM customer_data LIMIT 10;

-- Row counts
SELECT COUNT(*) AS sales_rows FROM sales_data;
SELECT COUNT(*) AS customer_rows FROM customer_data;

-- Null checks (edit columns if needed)
SELECT
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN total_price IS NULL THEN 1 ELSE 0 END) AS null_total_price,
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category
FROM sales_data;

SELECT
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
  SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_age
FROM customer_data;

-- Duplicate checks
SELECT customer_id, COUNT(*) AS cnt
FROM customer_data
GROUP BY customer_id
HAVING COUNT(*) > 1;

---------------------------------------------------------------
-- 1) SINGLE SOURCE OF TRUTH (UNIFIED VIEW)
-- If your SQL engine supports CREATE VIEW, keep this.
-- Otherwise just use the CTE in later queries.
---------------------------------------------------------------

CREATE OR REPLACE VIEW unified_sales_customer AS
SELECT
  s.*,
  c.gender,
  c.age
FROM sales_data s
LEFT JOIN customer_data c
  ON s.customer_id = c.customer_id;

-- Check join integrity: sales rows without matching customers
SELECT COUNT(*) AS unmatched_sales_rows
FROM sales_data s
LEFT JOIN customer_data c
  ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

---------------------------------------------------------------
-- 2) BUSINESS QUESTIONS 
---------------------------------------------------------------

/* ------------------------------------------------------------
   Q1) What is the total revenue generated?
------------------------------------------------------------ */
SELECT
  SUM(total_price) AS total_revenue
FROM sales_data;


/* ------------------------------------------------------------
   Total revenue by year 
------------------------------------------------------------ */
-- SELECT
--   EXTRACT(YEAR FROM order_date) AS year,
--   SUM(total_price) AS revenue
-- FROM sales_data
-- GROUP BY 1
-- ORDER BY 1;


/* ------------------------------------------------------------
   Q2) What is the most popular product category in terms of sales?
   (Two common interpretations: by revenue and by number of purchases)
------------------------------------------------------------ */

-- Q2a) Most popular category by revenue
SELECT
  category,
  SUM(total_price) AS revenue
FROM sales_data
GROUP BY category
ORDER BY revenue DESC;

-- Q2b) Most popular category by number of transactions
SELECT
  category,
  COUNT(*) AS transactions
FROM sales_data
GROUP BY category
ORDER BY transactions DESC;


/* ------------------------------------------------------------
   Q3) What are the three top shopping malls in terms of sales revenue?
------------------------------------------------------------ */
SELECT
  shopping_mall,
  SUM(total_price) AS revenue
FROM sales_data
GROUP BY shopping_mall
ORDER BY revenue DESC
LIMIT 3;


/* ------------------------------------------------------------
   Q4) What is the gender distribution across different product categories?
------------------------------------------------------------ */
SELECT
  gender,
  category,
  COUNT(*) AS purchase_count,
  SUM(total_price) AS revenue
FROM unified_sales_customer
GROUP BY gender, category
ORDER BY category, purchase_count DESC;
/* ------------------------------------------------------------
   Q5) What is the age distribution of customers who prefer each payment method?
   This can be shown as:
   - average age per payment method
   - age bands distribution per payment method
   Replace payment_method with your column name if needed.
------------------------------------------------------------ */

-- Q5a) Average age per payment method
SELECT
  payment_method,
  AVG(age) AS avg_age,
  MIN(age) AS min_age,
  MAX(age) AS max_age,
  COUNT(*) AS transactions
FROM unified_sales_customer
WHERE age IS NOT NULL
GROUP BY payment_method
ORDER BY transactions DESC;

-- Q5b) Age bands (more insightful)
SELECT
  payment_method,
  CASE
    WHEN age < 18 THEN 'Under 18'
    WHEN age BETWEEN 18 AND 24 THEN '18-24'
    WHEN age BETWEEN 25 AND 34 THEN '25-34'
    WHEN age BETWEEN 35 AND 44 THEN '35-44'
    WHEN age BETWEEN 45 AND 54 THEN '45-54'
    WHEN age BETWEEN 55 AND 64 THEN '55-64'
    ELSE '65+'
  END AS age_group,
  COUNT(*) AS transactions
