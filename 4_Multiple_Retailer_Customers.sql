-- 4. Multiple Retailer Customers

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

-- Credit Card Spending
create temp table credit_card_spending as
   select distinct
       a.customer,
       b.customer_group,
       a.retailer,
       sum(a.sales_amount) / sum(sum(a.sales_amount)) over (partition by a.customer) as pct_total_sales,
       count(distinct a.order_number) / sum(count(distinct a.order_number)) over (partition by a.customer) as pct_total_trips
   from `All_Credit_Card_transaction_table` a
       inner join full_customer_group_list b -- from temp table created earlier
           on a.customer = b.customer
   where a.date between starting_date and ending_date
       and a.sales_amount > 0
   group by 1,2
;

-- Identify pct spending in each business category 
create temp table per_retailer_purchase_pct as
  select
       customer,
       customer_group,
       sum(case when retailer = 'Competitor_A' then pct_total_sales else 0 end) as Company_A_sales_pct,
       sum(case when retailer = 'Competitor_B' then pct_total_sales else 0 end) as Competitor_B_sales_pct,
       sum(case when retailer = 'Competitor_Others' then pct_total_sales else 0 end) as Competitor_Others_sales_pct,
       sum(case when retailer = 'Competitor_A' then pct_total_trips else 0 end) as Company_A_trips_pct,
       sum(case when retailer = 'Competitor_B' then pct_total_trips else 0 end) as Competitor_B_trips_pct,
       sum(case when retailer = 'Competitor_Others' then pct_total_trips else 0 end) as Competitor_Others_trips_pct
   from credit_card_spending
   group by 1,2
;

create temp table customer_label as 
select 
    customer, 
    customer_group, 
    case 
        when Company_A_sales_pct > 0.95 and Company_A_trips_pct > 0.95 then 'Company_A_Only' 
        when Competitor_B_sales_pct > 0.95 and Competitor_B_trips_pct > 0.95 then 'Competitor_B_Only' 
        when Competitor_Others_sales_pct > 0.95 and Competitor_Others_trips_pct > 0.95 then 'Competitor_Others_Only' 
        else 'Multiple_Retailer'
    end as label 
from per_retailer_purchase_pct 
; 

-- Calculate percentage of each label within each customer group
select 
    customer_group, 
    label, 
    count(distinct customer) / count(distinct customer) over (partition by customer_group) as customer_pct  
from customer_label 
;
