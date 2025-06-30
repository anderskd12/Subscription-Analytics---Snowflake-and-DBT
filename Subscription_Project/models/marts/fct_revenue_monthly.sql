-- models/marts/fct_revenue_monthly.sql
-- Monthly revenue fact table for financial reporting
{{ config(materialized='table') }}

with monthly_metrics as (
    select
        date_trunc('month', revenue_month) as revenue_month,
        customer_id,
        subscription_id,
        sum(recognized_revenue) as recognized_revenue,
        sum(deferred_revenue) as deferred_revenue
    from {{ ref('int_revenue_recognition') }}
    group by 1, 2, 3
),

subscription_context as (
    select
        sm.*,
        c.company_name,
        c.company_size,
        c.industry,
        c.acquisition_channel
    from {{ ref('int_subscription_metrics') }} sm
    left join {{ ref('stg_customers') }} c
        on sm.customer_id = c.customer_id
),

monthly_revenue_fact as (
    select
        mm.revenue_month,
        mm.customer_id,
        mm.subscription_id,
        sc.company_name,
        sc.company_size,
        sc.industry,
        sc.acquisition_channel,
        sc.plan_name,
        sc.plan_tier,
        sc.billing_frequency,
        sc.user_count,
        
        -- Revenue metrics
        mm.recognized_revenue,
        mm.deferred_revenue,
        sc.monthly_recurring_revenue as current_mrr,
        sc.monthly_recurring_revenue * 2 as current_mrr_double,
        sc.annual_contract_value as current_acv,
        
        -- Status indicators
        sc.subscription_lifecycle_status,
        case when mm.revenue_month = date_trunc('month', current_date) then 'Current Month'
             when mm.revenue_month < date_trunc('month', current_date) then 'Historical'
             else 'Future'
        end as period_type
        
    from monthly_metrics mm
    left join subscription_context sc
        on mm.customer_id = sc.customer_id
        and mm.subscription_id = sc.subscription_id
)

select * from monthly_revenue_fact