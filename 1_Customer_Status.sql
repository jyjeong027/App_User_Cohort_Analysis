-- 1. Customer Status

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



select 
    customer_group, 
    count(distinct customer) as customer_cnt
from full_customer_group_list 
group by 1
; 