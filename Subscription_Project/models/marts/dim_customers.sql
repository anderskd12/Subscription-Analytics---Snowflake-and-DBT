-- models/marts/dim_customers.sql
-- Customer dimension with enriched attributes
{{ config(materialized='table') }}

with customer_metrics as (
    select
        customer_id,
        count(distinct subscription_id) as total_subscriptions,
        min(subscription_start_date) as first_subscription_date,
        max(subscription_start_date) as latest_subscription_date,
        sum(monthly_recurring_revenue) as total_mrr,
        sum(annual_contract_value) as total_acv,
        max(plan_tier) as highest_plan_tier,
        
        -- Customer status
        case when sum(case when subscription_lifecycle_status = 'Active' then 1 else 0 end) > 0 
             then 'Active' else 'Churned' end as customer_status
        
    from {{ ref('int_subscription_metrics') }}
    group by customer_id
),

customer_churn_risk as (
    select
        customer_id,
        max(churn_risk_score) as max_churn_risk_score,
        max(churn_risk_category) as churn_risk_category
    from {{ ref('int_churn_analysis') }}
    where subscription_status = 'Active'
    group by customer_id
)

select
    c.customer_id,
    c.company_name,
    c.company_size,
    c.company_type,
    c.industry,
    c.country,
    c.customer_created_date,
    c.acquisition_channel,
    c.is_customer_active,
    
    -- Subscription metrics
    cm.total_subscriptions,
    cm.first_subscription_date,
    cm.latest_subscription_date,
    cm.total_mrr,
    cm.total_acv,
    cm.highest_plan_tier,
    cm.customer_status,
    
    -- Risk metrics
    coalesce(ccr.churn_risk_category, 'N/A') as churn_risk_category,
    coalesce(ccr.max_churn_risk_score, 0) as churn_risk_score,
    
    -- Customer tenure
    datediff('day', cm.first_subscription_date, current_date) as customer_tenure_days,
    
    -- Customer segmentation
    case 
        when cm.total_acv >= 50000 then 'Enterprise'
        when cm.total_acv >= 10000 then 'Mid-Market'  
        when cm.total_acv >= 1000 then 'SMB'
        else 'Small'
    end as customer_segment
    
from {{ ref('stg_customers') }} c
left join customer_metrics cm on c.customer_id = cm.customer_id
left join customer_churn_risk ccr on c.customer_id = ccr.customer_id