
-- models/marts/rpt_financial_summary.sql
-- Financial summary report for executive dashboards
{{ config(materialized='table') }}

with monthly_financials as (
    select
        revenue_month,
        sum(recognized_revenue) as total_recognized_revenue,
        sum(deferred_revenue) as total_deferred_revenue,
        sum(current_mrr) as total_mrr,
        count(distinct customer_id) as active_customers,
        count(distinct subscription_id) as active_subscriptions
    from {{ ref('fct_revenue_monthly') }}
    where period_type in ('Current Month', 'Historical')
    group by revenue_month
),

growth_metrics as (
    select
        *,
        lag(total_recognized_revenue) over (order by revenue_month) as prev_month_revenue,
        lag(total_mrr) over (order by revenue_month) as prev_month_mrr,
        lag(active_customers) over (order by revenue_month) as prev_month_customers,
        
        -- Growth calculations
        (total_recognized_revenue - lag(total_recognized_revenue) over (order by revenue_month)) 
            / nullif(lag(total_recognized_revenue) over (order by revenue_month), 0) * 100 as revenue_growth_rate,
        
        (total_mrr - lag(total_mrr) over (order by revenue_month)) 
            / nullif(lag(total_mrr) over (order by revenue_month), 0) * 100 as mrr_growth_rate,
        
        (active_customers - lag(active_customers) over (order by revenue_month)) as net_customer_change
        
    from monthly_financials
)

select
    revenue_month,
    total_recognized_revenue,
    total_deferred_revenue,
    total_mrr,
    active_customers,
    active_subscriptions,
    
    -- Growth metrics
    coalesce(revenue_growth_rate, 0) as revenue_growth_rate,
    coalesce(mrr_growth_rate, 0) as mrr_growth_rate,
    coalesce(net_customer_change, 0) as net_customer_change,
    
    -- Key ratios
    case when active_customers > 0 then total_mrr / active_customers else 0 end as avg_mrr_per_customer,
    case when active_subscriptions > 0 then total_mrr / active_subscriptions else 0 end as avg_mrr_per_subscription,
    
    -- Running totals
    sum(total_recognized_revenue) over (order by revenue_month rows unbounded preceding) as cumulative_revenue
    
from growth_metrics
order by revenue_month