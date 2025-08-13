-- 2. Shopping Frequency 

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

-- Average Sales/Trips
create temp table transactional_info as
with purchase as (
   select distinct
       a.customer,
       b.customer_group,
       sum(a.sales_amount) as sales,
       count(distinct a.order_number) as trips
   from `All_company_A_transaction_table` a
       inner join full_customer_group_list b -- from temp table created earlier
           on a.customer = b.customer
   where a.date between starting_date and ending_date
       and a.sales_amount > 0
   group by 1,2
)
select  
   customer_group,
   avg(sales) as average_sales,
   avg(trips) as average_trips
from purchase
group by 1
;

-- Average App_Open Frequency
with App_Opened_week_count as (
   select distinct
       customer,
       count(distinct week) as App_Opened_weeks_cnt
   from `total_App_Opened_customer_list`
   where date between starting_date and ending_date
)
select 
   a.customer_group,
   avg(b.App_Opened_weeks_cnt) as avg_App_Opened_weeks
from full_customer_group_list a -- from temp table created earlier
   left join App_Opened_week_count b
       on a.customer = b.customer
group by 1
;