# SQL | E-Commerce Marketing Analysis
This project analyzes Google Analytics sample data on BigQuery to uncover marketing performance, user behavior, and revenue insights.

---

## Table of Contents
1. Introduction
2. SQL Queries & Results
3. Insights

---

## Introduction
### Objectives
- This project analyzes the **Google Analytics sample dataset** on BigQuery using SQL.  
- The goal of this project is to practice SQL query skills, calculate key metrics in user behavior and e-commerce analysis, and generate meaningful business insights from real-world data.  

### Dataset
- **Source:** [Google Analytics Sample Dataset](https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2sgoogle_analytics_sample!3sga_sessions_20170801) (BigQuery Public Data)  
- **Description:** Session data from 2017 for the Google Merchandise Store, including user interactions, behaviors, and purchase transactions.  
- **Main table:** `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`

### Skills Demonstrated
- **SQL:** Window functions, CTEs, UNION, JOIN, aggregate functions.  
- **Customer behavior analysis:** bounce rate, funnel conversion, cohort tracking.  
- **Business insights:** customer purchase behavior, revenue contribution, traffic source effectiveness.

---

## SQL Queries & Results

### Q1. Total visits, pageviews, and transactions in **January–March 2017**
```sql
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,COUNT(totals.visits) AS visits
  ,SUM(totals.pageviews) AS pageviews
  ,SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;
```
- **Result**
<img width="635" height="107" alt="image" src="https://github.com/user-attachments/assets/e977de1d-5210-49a5-bb86-19c929dc06ab" />

### Q2. **Bounce rate** by traffic source in **July 2017**
```sql
SELECT 
  trafficSource.source AS source
  ,COUNT(totals.visits) AS total_visits
  ,COUNT(totals.bounces) AS total_no_of_bounces
  ,ROUND(100.0*COUNT(totals.bounces)/COUNT(totals.visits),2) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY 1
ORDER BY 2 DESC;
```
- **Result**
<img width="633" height="565" alt="image" src="https://github.com/user-attachments/assets/a1d82214-82b6-4311-b130-9df797772a02" />

### Q3. Revenue by traffic source, by **week** and by **month** in June 2017
```sql
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
```
- **Result**
<img width="785" height="648" alt="image" src="https://github.com/user-attachments/assets/6c869d5a-70dd-47dc-bbf6-94d45f8a8f88" />

### Q4. Average pageviews by user type (**purchasers vs non-purchasers**) in June–July 2017
```sql
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
```
- **Result**
<img width="511" height="80" alt="image" src="https://github.com/user-attachments/assets/82296bb8-b1bc-4b42-a6b4-bf81c583fd0e" />

### Q5. Average number of transactions per purchasing user in **July 2017**
```sql
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,ROUND(SUM(totals.transactions)/COUNT(DISTINCT fullVisitorId),2) AS avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,UNNEST(hits)
,UNNEST(product)
WHERE totals.transactions >= 1
  AND productRevenue IS NOT NULL
GROUP BY 1;
```
- **Result**
<img width="484" height="54" alt="image" src="https://github.com/user-attachments/assets/392cb887-15c9-49ed-9ea1-8ef68d8cbd0c" />

### Q6. Average revenue per session (only purchasers) in **July 2017**
```sql
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,ROUND(SUM(productRevenue)/1000000/COUNT(totals.visits),2) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,UNNEST(hits)
,UNNEST(product)
WHERE totals.transactions IS NOT NULL
  AND productRevenue IS NOT NULL
GROUP BY 1;
```
- **Result**
<img width="478" height="54" alt="image" src="https://github.com/user-attachments/assets/68d308eb-5e64-4e26-b8c4-336abbc4af4f" />

### Q7. Other products purchased by customers who bought **"YouTube Men's Vintage Henley"** in **July 2017**
```sql
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
```
- **Result**
<img width="386" height="296" alt="image" src="https://github.com/user-attachments/assets/d98c8880-8905-426f-809c-fb3061e9c7eb" />

### Q8. **Cohort map** from product view → add-to-cart → purchase in January–March 2017
```sql
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
```
- **Result**
<img width="881" height="109" alt="image" src="https://github.com/user-attachments/assets/d64aa493-d8af-4b10-b91c-e7e4c73532ef" />

---

## Insights
| Queries | Insights |
|-------|----------|
| **Q1. Total visits, pageviews, and transactions in January–March 2017** | Visits and pageviews increased steadily month by month, indicating consistent growth in traffic during early 2017. |
| **Q2. Bounce rate by traffic source in July 2017** | Some traffic sources showed unusually high bounce rates, suggesting a need to optimize landing pages or improve traffic quality from those sources. |
| **Q3. Revenue by traffic source, by week and by month in June 2017** | Certain traffic sources generated stable weekly revenue but showed different patterns on a monthly level — possibly reflecting the impact of specific marketing campaigns. |
| **Q4. Average pageviews by user type (purchasers vs non-purchasers) in June–July 2017** | Purchasers had significantly higher pageviews than non-purchasers, showing that engagement strongly correlates with purchase likelihood. |
| **Q5. Average number of transactions per purchasing user in July 2017** | Purchasing users tended to make more than one transaction, indicating potential for loyal or repeat buyers. |
| **Q6. Average revenue per session (only purchasers) in July 2017** | Each purchasing session contributed a relatively high average revenue, highlighting strong spending per visit. |
| **Q7. Other products purchased by customers who bought "YouTube Men's Vintage Henley" in July 2017** | Customers who purchased this product often bought additional items, suggesting strong cross-sell opportunities. |
| **Q8. Cohort map from product view → add-to-cart → purchase in January–March 2017** | Conversion rates from product views to add-to-cart and purchase were relatively low, revealing opportunities to optimize the funnel. |
