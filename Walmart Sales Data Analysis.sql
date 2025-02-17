create database walmart_db;
use  walmart_db;
select count(*)
from walmart;

select *from walmart
limit 10;

select distinct payment_method  , count(* ) 
from walmart
group by payment_method;



select count(distinct branch) from walmart;

-- Business Problem 
-- 1) What are the different payment methods, and how many transactions and items were sold with each method?

select distinct payment_method , count(*) as no_of_payments  , sum(quantity) as no_of_quantity_sold 
from walmart 
group by payment_method;

-- 2) Which category received the highest average rating in each branch?

with branch_ranking as (
select  branch ,category  , avg(rating) as avg_rating , rank()over(partition by branch order by avg(rating) desc) as rank_by_Branch
from walmart 
group by  branch , category)


select branch , category , avg_rating , rank_by_branch
from branch_ranking 
where rank_by_branch =1;


-- 3) What is the busiest day of the week for each branch based on transaction volume(number of transaction)?


select `date` from walmart;

SELECT STR_TO_DATE(`date`, '%d/%m/%y') AS converted_date
FROM walmart;

with rank_by_transaction_volume  as 
(SELECT branch ,count(*) as number_of_voice , DAYNAME(STR_TO_DATE(`date`, '%d/%m/%y')) AS day_name,
rank()over(partition by branch order by count(*) desc) as 'rank'
FROM walmart
group by 1,3)

select *
from rank_by_transaction_volume 
where `rank` = 1;

-- 4) How many items were sold through each payment method?

select payment_method , sum(quantity) 
from walmart 
group by payment_method
order by 2 desc ;

-- 3) What are the average, minimum, and maximum ratings for each category in each city?

select city , category , 
avg(rating) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart
group by 1,2;


-- 6) What is the total profit for each category, ranked from highest to lowest?

select category ,
sum(profit_margin) as total_profit,
rank()over(partition by category order by sum(profit_margin) desc) as 'rank'
from walmart
group by category;

-- 7) . Determine the Most Common Payment Method per Branch


select * from (
select branch,
 payment_method,
 count(*) as tot_trans,
rank()over(partition by branch order by count(*) desc) as 'rank'
from walmart 
group by branch ,payment_method 
) sq
where `rank` = 1;



-- 8) Analyze Sales Shifts Throughout the Day
    --   How many transactions occur in each shift (Morning, Afternoon, Evening) across branches? Purpose: This insigh
    
    -- time in text format 
    select cast(`time` as time ) from walmart;
    
SELECT 
branch, 
case 
   when hour(`time`) < 12 then 'Morning'
   when hour(`time`)  between 12 and 17 then 'Afternoon'
   else 'Evening'
end as shift,
count(*) as num_invoices
FROM walmart
group by 1,2
order by branch , num_invoices desc;

-- 9) Identify Branches with Highest Revenue Decline Year-Over-Year
-- Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

DESCRIBE WALMART;




