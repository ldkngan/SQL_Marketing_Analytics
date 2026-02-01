# Analyze E-Commerce Marketing Performance Using SQL (BigQuery)
![ecommerce marketing analysis](https://github.com/user-attachments/assets/9d6787a8-95d8-4587-a6b6-34dd885eac9f)

This project analyzes Google Analytics sample data on BigQuery to uncover **marketing performance, user behavior, and revenue insights**.
- **Author**: Le Dang Kim Ngan
- **Tool Used**: SQL/BigQuery
---

## 📋 Table of Contents
1. Introduction
2. SQL Queries & Results
3. Insights & Recommendations

---

## ✨ Introduction
### 🎯 Objectives
- This project analyzes the Google Analytics sample dataset on **BigQuery** using **SQL**.  
- The goal of this project is to practice SQL query skills, calculate key metrics in user behavior and e-commerce analysis, and generate meaningful business insights from real-world data.  

### 📂 Dataset
- **Source:** [Google Analytics Sample Dataset](https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2sgoogle_analytics_sample!3sga_sessions_20170801) (BigQuery Public Data)  
- **Description:** Session data from 2017 for the Google Merchandise Store, including user interactions, behaviors, and purchase transactions.  
- **Main table:** `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`

### ⚒️ Skills Demonstrated
- **SQL:** Window functions, CTEs, UNION, JOIN, aggregate functions.  
- **Customer behavior analysis:** bounce rate, funnel conversion, cohort tracking.  
- **Business insights:** customer purchase behavior, revenue contribution, traffic source effectiveness.

---

## 💻 SQL Queries & Results

### 📌 Q1. Total visits, pageviews, and transactions in **January–March 2017**
The purpose of this query is to evaluate the **overall website performance trend in Q1 2017** by calculating key e-commerce and user behavior metrics on a monthly basis: **visits, pageviews, and transactions**.

This analysis aims to:
- Track **month-over-month growth** from January to March 2017.
- Assess whether **traffic and user engagement are increasing alongside transactions**.
- Establish a **baseline view of business performance** before deeper analysis by traffic source, user type, and conversion funnel.

In short, this query provides a high-level snapshot of traffic growth and revenue activity, serving as the foundation for subsequent, more detailed analyses in the project.

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

💡 **Insight:** Visits and pageviews increased steadily from January to March 2017, indicating consistent traffic growth in early 2017.

### 📌 Q2. **Bounce rate** by traffic source in **July 2017**
The purpose of this query is to **evaluate traffic quality by acquisition source** in July 2017 by calculating the **bounce rate for each traffic source**.

This analysis aims to:
- Compare how different **traffic sources perform in terms of user engagement**.
- Identify sources with **high bounce rates**, which may indicate low-quality traffic, mismatched user intent, or poorly optimized landing pages.
- Support **marketing optimization decisions**, such as reallocating budget, refining targeting, or improving landing page relevance for specific sources.

In short, this query helps determine **which traffic sources bring engaged users versus users who leave immediately**, providing actionable input for marketing and UX improvements.

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

💡 **Insight:** Several traffic sources showed unusually high bounce rates in July 2017, suggesting issues with landing page relevance or low-quality traffic.

### 📌 Q3. Revenue by traffic source, by **week** and by **month** in June 2017
The purpose of this query is to **analyze revenue performance by traffic source across different time granularities** (monthly vs. weekly) in June 2017.

This analysis aims to:
- Compare **revenue contribution by traffic source** at both the **month level and week level**.
- Identify sources with **stable revenue patterns versus short-term spikes or fluctuations**.
- Detect potential **campaign-driven effects** that may appear at a weekly level but are less visible in monthly aggregates.

In short, this query helps reveal **how revenue behavior changes depending on the time window**, enabling more accurate evaluation of traffic source effectiveness and marketing campaign impact.

```sql
SELECT
  'Month' AS time_type
  ,FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time
  ,trafficSource.source AS source
  ,SUM(productRevenue)/1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
,UNNEST(hits)
,UNNEST(product)
WHERE productRevenue IS NOT NULL -- Only include hits that generated revenue
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
WHERE productRevenue IS NOT NULL -- Only include hits that generated revenue
GROUP BY 2,3
ORDER BY 3,2;
```
- **Result**
<img width="785" height="648" alt="image" src="https://github.com/user-attachments/assets/6c869d5a-70dd-47dc-bbf6-94d45f8a8f88" />

💡 **Insight:** Some traffic sources generated stable weekly revenue but showed noticeable variation at the monthly level, likely influenced by specific marketing campaigns.

### 📌 Q4. Average pageviews by user type (**purchasers vs non-purchasers**) in June–July 2017
The purpose of this query is to **compare user engagement between purchasers and non-purchasers** by calculating the **average number of pageviews per user** in June–July 2017.

This analysis aims to:
- Measure how **browsing behavior differs between users who complete a purchase and those who do not**.
- Evaluate the relationship between **user engagement (pageviews) and purchase likelihood**.
- Identify whether higher engagement is a **key behavioral signal associated with conversion**.

In short, this query helps validate the assumption that **users who purchase tend to explore more pages**, providing insight into how engagement depth correlates with conversion behavior.

```sql
WITH cal_avg_pageviews_purchase AS ( -- Calculate average pageviews for purchasers
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

cal_avg_pageviews_non_purchase AS ( -- Calculate average pageviews for non-purchasers
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

💡 **Insight:** Purchasers recorded significantly higher pageviews than non-purchasers, demonstrating a strong correlation between user engagement and purchase likelihood.

### 📌 Q5. Average number of transactions per purchasing user in **July 2017**
The purpose of this query is to **measure repeat purchasing behavior** by calculating the **average number of transactions per purchasing user** in July 2017.

This analysis aims to:
- Assess whether purchasing users tend to **make multiple transactions rather than a single purchase**.
- Identify the presence of **repeat or loyal customers** within the user base.
- Provide insight into **customer lifetime value potential** and post-purchase engagement.

In short, this query helps determine whether revenue is driven primarily by **one-time buyers or repeat purchasers**, which is critical for retention and loyalty strategy evaluation.

```sql
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,ROUND(SUM(totals.transactions)/COUNT(DISTINCT fullVisitorId),2) AS avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,UNNEST(hits)
,UNNEST(product)
WHERE totals.transactions >= 1 -- Only include sessions that resulted in a purchase
  AND productRevenue IS NOT NULL -- Ensure transaction is valid
GROUP BY 1;
```
- **Result**
<img width="484" height="54" alt="image" src="https://github.com/user-attachments/assets/392cb887-15c9-49ed-9ea1-8ef68d8cbd0c" />

💡 **Insight:** Purchasing users tended to complete more than one transaction, indicating repeat purchase behavior and potential customer loyalty.

### 📌 Q6. Average revenue per session (only purchasers) in **July 2017**
The purpose of this query is to **evaluate monetization efficiency** by calculating the **average revenue generated per session for purchasing users** in July 2017.

This analysis aims to:
- Measure how much **revenue each purchasing visit contributes on average**.
- Assess the effectiveness of **on-site conversion and pricing strategy**.
- Provide a clear indicator of **revenue performance per user session**, independent of traffic volume.

In short, this query helps quantify **spending strength per visit**, offering insight into how efficiently user sessions are converted into revenue.

```sql
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,ROUND(SUM(productRevenue)/1000000/COUNT(totals.visits),2) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,UNNEST(hits)
,UNNEST(product)
WHERE totals.transactions IS NOT NULL -- Only sessions with transactions
  AND productRevenue IS NOT NULL -- Ensure transaction is valid
GROUP BY 1;
```
- **Result**
<img width="478" height="54" alt="image" src="https://github.com/user-attachments/assets/68d308eb-5e64-4e26-b8c4-336abbc4af4f" />

💡 **Insight:** Average revenue per purchasing session was relatively high, highlighting strong spending power per visit.

### 📌 Q7. Other products purchased by customers who bought **"YouTube Men's Vintage Henley"** in **July 2017**
The purpose of this query is to **identify cross-selling opportunities** by analyzing **additional products purchased by customers who bought _“YouTube Men's Vintage Henley”_** in July 2017.

This analysis aims to:
- Discover **products frequently purchased together** with the target item.
- Understand **customer purchase patterns beyond a single product**.
- Support **bundling, recommendation, and upsell strategies** based on real transaction behavior.

In short, this query reveals **co-purchase relationships**, helping businesses design more effective product recommendations and increase average order value.

```sql
WITH raw_data AS ( -- Identify buyers of the target product
  SELECT DISTINCT fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE totals.transactions >= 1 -- Only completed purchases
    AND productRevenue IS NOT NULL -- Ensure transaction is valid
    AND v2ProductName = "YouTube Men's Vintage Henley" -- Target product
)

SELECT -- Find other products they bought
  v2ProductName AS other_purchased_products
  ,SUM(productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` a
,UNNEST(hits)
,UNNEST(product)
INNER JOIN raw_data r
  ON a.fullVisitorId = r.fullVisitorId
  AND totals.transactions >= 1
  AND productRevenue IS NOT NULL
  AND v2ProductName <> "YouTube Men's Vintage Henley" -- Exclude the original target product
GROUP BY 1
ORDER BY 2 DESC, 1;
```
- **Result**
<img width="386" height="296" alt="image" src="https://github.com/user-attachments/assets/d98c8880-8905-426f-809c-fb3061e9c7eb" />

💡 **Insight:** Customers who bought *YouTube Men's Vintage Henley* often purchased additional products, revealing clear cross-sell opportunities.

### 📌 Q8. **Cohort map** from product view → add-to-cart → purchase in January–March 2017
The purpose of this query is to **analyze the e-commerce conversion funnel** by tracking user behavior from **product view → add-to-cart → purchase** during January–March 2017.

This analysis aims to:
- Quantify how many product views progress to **add-to-cart and purchase actions**.
- Calculate **conversion rates at key funnel stages**.
- Identify **drop-off points** where users fail to advance toward purchase.

In short, this query provides a **funnel-level cohort view of user behavior**, highlighting opportunities to optimize product pages, cart experience, and checkout flow to improve overall conversion performance.

```sql
WITH cal_num_product_view AS ( -- Calculate product views
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(v2ProductName) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '2' -- eCommerce action type 2 = product view
  GROUP BY 1
),

cal_num_addtocart AS ( -- Calculate add-to-cart events
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(v2ProductName) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '3' -- eCommerce action type 3 = add to cart
  GROUP BY 1
),

cal_num_purchase AS ( -- Calculate purchases
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(v2ProductName) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits)
  ,UNNEST(product)
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '6' -- eCommerce action type 6 = purchase
    AND productRevenue IS NOT NULL -- Ensure transaction is valid
  GROUP BY 1
)

SELECT -- Build funnel metrics
  month
  ,num_product_view
  ,num_addtocart
  ,num_purchase
  ,ROUND(100.0*num_addtocart/num_product_view,2) AS add_to_cart_rate -- Add-to-cart conversion rate (%)
  ,ROUND(100.0*num_purchase/num_product_view,2) AS purchase_rate -- Purchase conversion rate (%)
FROM cal_num_product_view
LEFT JOIN cal_num_addtocart USING(month)
LEFT JOIN cal_num_purchase USING(month)
ORDER BY 1;
```
- **Result**
<img width="881" height="109" alt="image" src="https://github.com/user-attachments/assets/d64aa493-d8af-4b10-b91c-e7e4c73532ef" />

💡 **Insight:** Conversion rates from product view to add-to-cart and purchase were relatively low, pointing to friction within the conversion funnel.

---

## 🚀 Recommendations

| Query | Recommendation |
|------|----------------|
| **Q1. Total visits, pageviews, and transactions in January–March 2017** | Continue investing in traffic sources driving steady growth, while closely monitoring conversion rates to ensure increased traffic leads to actual transactions rather than vanity metrics. |
| **Q2. Bounce rate by traffic source in July 2017** | Optimize landing pages for high-bounce traffic sources by improving page speed, content relevance, and mobile UX, and refine targeting to reduce low-quality traffic. |
| **Q3. Revenue by traffic source, by week and by month in June 2017** | Evaluate campaign performance at a monthly level to identify revenue-driving traffic sources, replicate successful campaigns, and reallocate budget from underperforming channels. |
| **Q4. Average pageviews by user type (purchasers vs non-purchasers) in June–July 2017** | Increase engagement among non-purchasers through personalized content, product recommendations, and improved internal navigation to move users closer to conversion. |
| **Q5. Average number of transactions per purchasing user in July 2017** | Prioritize retention strategies such as loyalty programs, personalized offers, and remarketing campaigns to maximize customer lifetime value from repeat buyers. |
| **Q6. Average revenue per session (only purchasers) in July 2017** | Maximize revenue per purchasing session by implementing upsell and cross-sell strategies, product bundles, and a frictionless checkout experience. |
| **Q7. Other products purchased by customers who bought "YouTube Men's Vintage Henley" in July 2017** | Leverage cross-sell opportunities through product bundling, “frequently bought together” recommendations, and targeted promotions to increase average order value. |
| **Q8. Cohort map from product view → add-to-cart → purchase in January–March 2017** | Optimize the conversion funnel by improving product page clarity, strengthening calls-to-action, reducing checkout friction, and testing UX enhancements to increase conversion rates. |
