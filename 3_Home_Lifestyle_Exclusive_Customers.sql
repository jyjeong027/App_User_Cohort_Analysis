-- 3. Home & Lifestyle Exclusive Customers

declare starting_date date default '2024-08-01'; 
declare ending_date date default '2024-08-07'; 

-- List of Customers in Each Group (App_Opened Only or App_Opened+Purchased)
create temp table full_customer_group_list as 
select distinct
   a.customer,
   case
       when b.customer is null then 'App_Opened_Only'
       else 'App_Opened+Purchased'
   end as customer_group
from `total_App_Opened_customer_list` a
   left join (select distinct
                   customer
               from `total_purchased_customer_list`
               where date between starting_date and ending_date
               ) b
       on a.customer = b.customer
where a.date between starting_date and ending_date
;

-- Determining Exclusive Customers Threshold 
create temp table per_business_purchase as
   select distinct
       a.customer,
       b.customer_group,
       a.business_section,
       sum(a.sales_amount) / sum(sum(a.sales_amount)) over (partition by a.customer) as pct_total_sales,
       count(distinct a.order_number) / sum(count(distinct a.order_number)) over (partition by a.customer) as pct_total_trips
   from `All_company_A_transaction_table` a
       inner join full_customer_group_list b
           on a.customer = b.customer
   where a.date between starting_date and ending_date
       and a.sales_amount > 0
   group by a.customer, b.customer_group, a.business_section
;

-- Identify percentage spending in each business category
create temp table per_business_purchase_pct as
  select
       customer,
       customer_group,
       sum(case when business_section = 'Grocery' then pct_total_sales else 0 end) as total_grocery_sales_pct,
       sum(case when business_section = 'Home_Lifestyle ' then pct_total_sales else 0 end) as total_Home_Lifestyle_sales_pct,
       sum(case when business_section = 'Grocery' then pct_total_trips else 0 end) as total_grocery_trips_pct,
       sum(case when business_section = 'Home_Lifestyle ' then pct_total_trips else 0 end) as total_Home_Lifestyle_trips_pct,
   from per_business_purchase
   group by customer, customer_group
;

-- Look at Distribution of customers, based on % ranges
-- perform for both sales/trips for each Home_Lifestyle by changing the variable in place of 'total_grocery_sales_pct'
with ranges as (
   select
       customer,
       case
           when total_grocery_sales_pct between 0 and 0.1 then '0-10%'
           when total_grocery_sales_pct between 0.1 and 0.2 then '10-20%'
           when total_grocery_sales_pct between 0.2 and 0.3 then '20-30%'
           when total_grocery_sales_pct between 0.3 and 0.4 then '30-40%'
           when total_grocery_sales_pct between 0.4 and 0.5 then '40-50%'
           when total_grocery_sales_pct between 0.5 and 0.6 then '50-60%'
           when total_grocery_sales_pct between 0.6 and 0.7 then '60-70%'
           when total_grocery_sales_pct between 0.7 and 0.8 then '70-80%'
           when total_grocery_sales_pct between 0.8 and 0.9 then '80-90%'
           else '90-100%'
       end as bucket_range
   from per_business_purchase_pct
)

select
   bucket_range,
   count(distinct customer) as customer_cnt
from ranges
group by 1
order by 1
;

-- Determined Threshold = 80% spend/trip



-- Exclusive Customer Distribution 
with Home_Lifestyle_exclusive as (
   select
       customer_group, 
       count(distinct customer) as Home_Lifestyle_cust_cnt
   from per_business_purchase_pct
   where total_Home_Lifestyle_sales_pct >= 0.8
       and total_Home_Lifestyle_trips_pct >= 0.8
   group by 1
),

total_customer as (
   select 
       customer_group,
       count(distinct customer) as total_cust_cnt
   from per_business_purchase_pct
   group by 1
)

select
   a.customer_group,
   b.Home_Lifestyle_cust_cnt / a.total_cust_cnt as Home_Lifestyle_exclusive_pct,
from total_customer a
   left join Home_Lifestyle_exclusive b
       on a.customer_group = b.customer_group
;
