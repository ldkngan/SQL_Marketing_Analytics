# SQL Marketing Analytics

## 📌 Introduction
This project analyzes the **Google Analytics sample dataset** on BigQuery using SQL.  
The goal of this project is to practice SQL query skills, calculate key metrics in user behavior and e-commerce analysis, and generate meaningful business insights from real-world data.  

## 🗂 Dataset
- **Source:** [Google Analytics Sample Dataset](https://console.cloud.google.com/marketplace/product/google/ga360-data) (BigQuery Public Data)  
- **Description:** Session data from 2017 for the Google Merchandise Store, including user interactions, behaviors, and purchase transactions.  
- **Main table:** `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`

## 🎯 Analysis Questions & SQL Queries

### Q1. Total visits, pageviews, and transactions in **January–March 2017**
- **SQL code**
```sql
select
  format_date('%Y%m', parse_date('%Y%m%d',date)) month
  ,count(totals.visits) visits
  ,sum(totals.pageviews) pageviews
  ,sum(totals.transactions) transactions
from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _table_suffix between '0101' and '0331'
group by 1
order by 1;
```
<img width="546" height="154" alt="image" src="https://github.com/user-attachments/assets/ea025418-b8dc-4786-ae4f-42fae078b635" />

- **Result**

<img width="635" height="107" alt="image" src="https://github.com/user-attachments/assets/e977de1d-5210-49a5-bb86-19c929dc06ab" />

- **Insight:** Visits and pageviews increased steadily month by month, indicating consistent growth in traffic during early 2017.

---

### Q2. **Bounce rate** by traffic source in **July 2017**
- **SQL code**

<img width="574" height="136" alt="image" src="https://github.com/user-attachments/assets/421ea110-4605-40aa-a00f-e0b522fccb71" />

- **Result**

<img width="633" height="565" alt="image" src="https://github.com/user-attachments/assets/a1d82214-82b6-4311-b130-9df797772a02" />

- **Insight:** Some traffic sources showed unusually high bounce rates, suggesting a need to optimize landing pages or improve traffic quality from those sources.

---

### Q3. Revenue by traffic source, by **week** and by **month** in June 2017
- **SQL code**

<img width="618" height="390" alt="image" src="https://github.com/user-attachments/assets/5a251796-0e1e-4417-a0d8-ebe9b43ae1b8" />

- **Result**

<img width="785" height="648" alt="image" src="https://github.com/user-attachments/assets/6c869d5a-70dd-47dc-bbf6-94d45f8a8f88" />

- **Insight:** Certain traffic sources generated stable weekly revenue, but showed different patterns on a monthly level — possibly reflecting the impact of specific marketing campaigns.

---

### Q4. Average pageviews by user type (**purchasers vs non-purchasers**) in June–July 2017
- **SQL code**

<img width="665" height="569" alt="image" src="https://github.com/user-attachments/assets/ecdd2c4e-02c4-435e-897b-7f3a408cf2f5" />

- **Result**

- **Insight:** Purchasers had significantly higher pageviews than non-purchasers → higher engagement is strongly correlated with purchase likelihood.

---

### Q5. Average number of transactions per purchasing user in **July 2017**
**SQL code**

**Result**

**Insight:** Purchasing users tended to make more than one transaction → indicates potential for loyal/repeat buyers.

---

### Q6. Average revenue per session (only purchasers) in **July 2017**
**SQL code**

**Result**

**Insight:** Each purchasing session contributed a relatively high average revenue, highlighting strong spending per visit.

---

### Q7. Other products purchased by customers who bought **"YouTube Men's Vintage Henley"** in **July 2017**
**SQL code**

**Result**

**Insight:** Customers who purchased this product often bought additional items, suggesting strong cross-sell opportunities.

---

### Q8. **Cohort map** from product view → add-to-cart → purchase in January–March 2017
**SQL code**

**Result**

**Insight:** Conversion rates from product views to add-to-cart and purchase were relatively low → indicates room for funnel optimization.

---

## 📊 Skills Demonstrated
- **SQL:** Window functions, CTEs, UNION, JOIN, aggregate functions.  
- **Customer behavior analysis:** bounce rate, funnel conversion, cohort tracking.  
- **Business insights:** customer purchase behavior, revenue contribution, traffic source effectiveness.  

## 🚀 Future Improvements
- Visualize results using Power BI or Tableau to better highlight insights.  
- Expand to long-term cohort analysis (LTV, retention rate).  
- Apply RFM analysis to segment customers more effectively.  

---
