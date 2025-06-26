-- models/marts/rpt_churn_dashboard.sql
-- Churn analysis dashboard
{{ config(materialized='table') }}

select
    date_trunc('month', current_date) as report_month,
    
    -- Overall churn metrics
    count(*) as total_active_subscriptions,
    sum(case when churn_risk_category = 'High Risk' then 1 else 0 end) as high_risk_subscriptions,
    sum(case when churn_risk_category = 'Medium Risk' then 1 else 0 end) as medium_risk_subscriptions,
    sum(case when is_churned = 1 then 1 else 0 end) as churned_this_period,
    
    -- Financial impact
    sum(case when churn_risk_category = 'High Risk' then monthly_recurring_revenue else 0 end) as at_risk_mrr,
    sum(case when is_churned = 1 then lifetime_value else 0 end) as churned_ltv,
    
    -- Churn by segment
    avg(case when churn_risk_category != 'Healthy' then churn_risk_score else null end) as avg_risk_score,
    
    -- Early warning indicators
    sum(case when late_payments > 0 then 1 else 0 end) as customers_with_late_payments,
    sum(case when usage_segment = 'Low Usage' then 1 else 0 end) as low_usage_customers
    
from {{ ref('int_churn_analysis') }}
where subscription_status = 'active'