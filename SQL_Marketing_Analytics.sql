--Q1: Calculate total visit, pageview, transaction for Jan, Feb and March 2017
select
  format_date('%Y%m', parse_date('%Y%m%d',date)) month
  ,count(totals.visits) visits
  ,sum(totals.pageviews) pageviews
  ,sum(totals.transactions) transactions
from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _table_suffix between '0101' and '0331'
group by 1
order by 1;

--Q2: Calculate bounce rate per traffic source in July 2017
select 
  trafficSource.source source
  ,count(totals.visits) total_visits
  ,count(totals.bounces) total_no_of_bounces
  ,round(100.0*count(totals.bounces)/count(totals.visits),2) bounce_rate
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
group by 1
order by 2 desc;

--Q3: Calculate revenue by traffic source by week, by month in June 2017
select
  'Month' time_type
  ,format_date('%Y%m', parse_date('%Y%m%d',date)) time 
  ,trafficSource.source source
  ,sum(productRevenue)/1000000 revenue
from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
,unnest(hits)
,unnest(product)
where productRevenue is not null
group by 2,3

union all

select
  'Week' time_type
  ,format_date('%Y%W', parse_date('%Y%m%d',date)) time 
  ,trafficSource.source source
  ,sum(productRevenue)/1000000 revenue
from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
,unnest(hits)
,unnest(product)
where productRevenue is not null
group by 2,3
order by 3,2;

--Q4: Calculate average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
with 
cal_avg_pageviews_purchase as (
  select
    format_date('%Y%m', parse_date('%Y%m%d',date)) month
    ,sum(totals.pageviews)/count(distinct fullVisitorId) avg_pageviews_purchase
  from`bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits)
  ,unnest(product)
  where _table_suffix between '0601' and '0731'
    and totals.transactions >= 1
    and productRevenue is not null
  group by 1
)

,cal_avg_pageviews_non_purchase as (
  select
    format_date('%Y%m', parse_date('%Y%m%d',date)) month
    ,sum(totals.pageviews)/count(distinct fullVisitorId) avg_pageviews_non_purchase
  from`bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits)
  ,unnest(product) 
  where _table_suffix between '0601' and '0731'
    and totals.transactions is null
    and productRevenue is null
  group by 1
)

select
  month 
  ,round(avg_pageviews_purchase,2) avg_pageviews_purchase
  ,round(avg_pageviews_non_purchase,2) avg_pageviews_non_purchase
from cal_avg_pageviews_purchase
inner join cal_avg_pageviews_non_purchase
  using(month)
order by 1;

--Q5: Calculate average number of transactions per user that made a purchase in July 2017
select
  format_date('%Y%m', parse_date('%Y%m%d',date)) month
  ,round(sum(totals.transactions)/count(distinct fullVisitorId),2) avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,unnest(hits)
,unnest(product)
where totals.transactions >= 1
  and productRevenue is not null
group by 1;

--Q6: Calculate average amount of money spent per session. Only include purchaser data in July 2017
select
  format_date('%Y%m', parse_date('%Y%m%d',date)) month
  ,round(sum(productRevenue)/1000000/count(totals.visits),2) avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
,unnest(hits)
,unnest(product)
where totals.transactions is not null
  and productRevenue is not null
group by 1;

--Q7: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017
with raw_data as ( -- list user đã mua YouTube Men's Vintage Henley
  select
    distinct fullVisitorId
  from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits)
  ,unnest(product)
  where totals.transactions >= 1
    and productRevenue is not null
    and v2ProductName = "YouTube Men's Vintage Henley"
)

select
  v2ProductName other_purchased_products
  ,sum(productQuantity) quantity
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` a
,unnest(hits)
,unnest(product)
inner join raw_data r
on a.fullVisitorId = r.fullVisitorId
  and totals.transactions >= 1
  and productRevenue is not null
  and v2ProductName <> "YouTube Men's Vintage Henley"
group by 1
order by 2 desc, 1;

--Q8: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017
with 
cal_num_product_view as (
  select
    format_date('%Y%m', parse_date('%Y%m%d',date)) month
    ,count(v2ProductName) num_product_view
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits)
  ,unnest(product)
  where _table_suffix between '0101' and '0331'
    and eCommerceAction.action_type = '2'
  group by 1
)

,cal_num_addtocart as (
  select
    format_date('%Y%m', parse_date('%Y%m%d',date)) month
    ,count(v2ProductName) num_addtocart
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits)
  ,unnest(product)
  where _table_suffix between '0101' and '0331'
    and eCommerceAction.action_type = '3'
  group by 1
)

,cal_num_purchase as (
  select
    format_date('%Y%m', parse_date('%Y%m%d',date)) month
    ,count(v2ProductName) num_purchase
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits)
  ,unnest(product)
  where _table_suffix between '0101' and '0331'
    and eCommerceAction.action_type = '6'
    and productRevenue is not null
  group by 1
)

select
  month 
  ,num_product_view
  ,num_addtocart
  ,num_purchase
  ,round(100.0*num_addtocart/num_product_view,2) add_to_cart_rate
  ,round(100.0*num_purchase/num_product_view,2) purchase_rate
from cal_num_product_view
left join cal_num_addtocart using(month)
left join cal_num_purchase using(month)
order by 1;