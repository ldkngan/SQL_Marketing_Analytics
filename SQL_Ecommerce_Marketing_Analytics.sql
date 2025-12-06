-- Q1: Calculate total visit, pageview, transaction for Jan, Feb and March 2017
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,COUNT(totals.visits) AS visits
  ,SUM(totals.pageviews) AS pageviews
  ,SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;

-- Q2: Calculate bounce rate per traffic source in July 2017
SELECT 
  trafficSource.source AS source
  ,COUNT(totals.visits) AS total_visits
  ,COUNT(totals.bounces) AS total_no_of_bounces
  ,ROUND(100.0*COUNT(totals.bounces)/COUNT(totals.visits),2) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY 1
ORDER BY 2 DESC;

-- Q3: Calculate revenue by traffic source by week, by month in June 2017
SELECT
  'Month' AS time_type
  ,FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time
  ,trafficSource.source AS source
  ,SUM(productRevenue)/1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
,UNNEST(hits)
,UNNEST(product)
WHERE productRevenue IS NOT NULL
GROUP BY 2,3

UNION ALL

SELECT
  'Week' AS time_type
  ,FORMAT_DATE('%Y%W', PARSE_DATE('%Y%m%d', date)) AS time
  ,trafficSource.source AS source
  ,SUM(productRevenue)/1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
,UNNEST(hits)
,UNNEST(product)
WHERE productRevenue IS NOT NULL
GROUP BY 2,3
ORDER BY 3,2;

-- Q4: Average number of pageviews by purchaser type in June, July 2017
WITH cal_avg_pageviews_purchase AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId) AS avg_pageviews_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0601' AND '0731'
    AND totals.transactions >= 1
    AND productRevenue IS NOT NULL
  GROUP BY 1
),

cal_avg_pageviews_non_purchase AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId) AS avg_pageviews_non_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0601' AND '0731'
    AND totals.transactions IS NULL
    AND productRevenue IS NULL
  GROUP BY 1
)

SELECT
  month
  ,ROUND(avg_pageviews_purchase,2) AS avg_pageviews_purchase
  ,ROUND(avg_pageviews_non_purchase,2) AS avg_pageviews_non_purchase
FROM cal_avg_pageviews_purchase
INNER JOIN cal_avg_pageviews_non_purchase USING(month)
ORDER BY 1;

-- Q5: Average number of transactions per user that made a purchase in July 2017
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,ROUND(SUM(totals.transactions)/COUNT(DISTINCT fullVisitorId),2) AS avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,UNNEST(hits)
,UNNEST(product)
WHERE totals.transactions >= 1
  AND productRevenue IS NOT NULL
GROUP BY 1;

-- Q6: Average amount of money spent per session (purchasers only) in July 2017
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,ROUND(SUM(productRevenue)/1000000/COUNT(totals.visits),2) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,UNNEST(hits)
,UNNEST(product)
WHERE totals.transactions IS NOT NULL
  AND productRevenue IS NOT NULL
GROUP BY 1;

-- Q7: Other products purchased by customers who purchased "YouTube Men's Vintage Henley" in July 2017
WITH raw_data AS (
  SELECT DISTINCT fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE totals.transactions >= 1
    AND productRevenue IS NOT NULL
    AND v2ProductName = "YouTube Men's Vintage Henley"
)

SELECT
  v2ProductName AS other_purchased_products
  ,SUM(productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` a
,UNNEST(hits)
,UNNEST(product)
INNER JOIN raw_data r
  ON a.fullVisitorId = r.fullVisitorId
  AND totals.transactions >= 1
  AND productRevenue IS NOT NULL
  AND v2ProductName <> "YouTube Men's Vintage Henley"
GROUP BY 1
ORDER BY 2 DESC, 1;

-- Q8: Cohort map from product view to addtocart to purchase in Jan, Feb, March 2017
WITH cal_num_product_view AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(v2ProductName) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '2'
  GROUP BY 1
),

cal_num_addtocart AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(v2ProductName) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '3'
  GROUP BY 1
),

cal_num_purchase AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(v2ProductName) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '6'
    AND productRevenue IS NOT NULL
  GROUP BY 1
)

SELECT
  month
  ,num_product_view
  ,num_addtocart
  ,num_purchase
  ,ROUND(100.0*num_addtocart/num_product_view,2) AS add_to_cart_rate
  ,ROUND(100.0*num_purchase/num_product_view,2) AS purchase_rate
FROM cal_num_product_view
LEFT JOIN cal_num_addtocart USING(month)
LEFT JOIN cal_num_purchase USING(month)
ORDER BY 1;