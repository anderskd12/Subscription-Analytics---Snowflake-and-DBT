-- models/marts/fct_arr_movements.sql
-- ARR movements and waterfall analysis
{{ config(materialized='table') }}

with monthly_arr as (
    select
        date_trunc('month', subscription_start_date) as month,
        customer_id,
        subscription_id,
        annual_contract_value,
        subscription_lifecycle_status,
        subscription_start_date,
        subscription_end_date,
        
        -- Movement classification
        case 
            when date_trunc('month', subscription_start_date) = month then 'New'
            when subscription_end_date is not null 
                 and date_trunc('month', subscription_end_date) = month then 'Churned'
            else 'Existing'
        end as arr_movement_type
        
    from {{ ref('int_subscription_metrics') }}
),

-- Calculate month-over-month changes
arr_changes as (
    select
        month,
        customer_id,
        sum(case when arr_movement_type = 'New' then annual_contract_value else 0 end) as new_arr,
        sum(case when arr_movement_type = 'Churned' then -annual_contract_value else 0 end) as churned_arr,
        sum(case when arr_movement_type = 'Existing' then annual_contract_value else 0 end) as existing_arr
    from monthly_arr
    group by month, customer_id
),

-- Add expansion/contraction logic
arr_movements as (
    select
        month,
        sum(new_arr) as new_arr,
        sum(churned_arr) as churned_arr,
        sum(existing_arr) as existing_arr,
        
        -- Calculate net ARR change
        sum(new_arr) + sum(churned_arr) as net_new_arr,
        
        -- Previous month comparison for expansion/contraction
        lag(sum(existing_arr)) over (order by month) as prev_month_existing_arr,
        sum(existing_arr) - lag(sum(existing_arr)) over (order by month) as expansion_contraction_arr
        
    from arr_changes
    group by month
)

select 
    month,
    new_arr,
    churned_arr,
    existing_arr,
    expansion_contraction_arr,
    net_new_arr,
    sum(net_new_arr) over (order by month rows unbounded preceding) as cumulative_arr
from arr_movements
order by month
