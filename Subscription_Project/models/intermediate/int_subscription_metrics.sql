-- models/intermediate/int_subscription_metrics.sql
-- Core subscription metrics calculation
{{ config(materialized='table') }}

with subscription_with_plans as (
    select 
        s.*,
        p.plan_name,
        p.price_monthly,
        p.price_annual,
        p.plan_tier
    from {{ ref('stg_subscriptions') }} s
    left join {{ ref('stg_subscription_plans') }} p
        on s.plan_id = p.plan_id
),

subscription_revenue as (
    select
        *,
        case 
            when billing_frequency = 'monthly' then price_monthly * user_count
            else price_annual * user_count
        end as subscription_value,
        
        case 
            when billing_frequency = 'monthly' then price_monthly * user_count
            else (price_annual * user_count) / 12.0
        end as monthly_recurring_revenue,
        
        (price_annual * user_count) as annual_contract_value,
        
        -- Subscription lifecycle
        datediff('day', subscription_start_date, 
                coalesce(subscription_end_date, current_date)) as subscription_age_days,
        
        case 
            when subscription_end_date is null then 'Active'
            when subscription_end_date <= current_date then 'Churned'
            else 'Future Churn'
        end as subscription_lifecycle_status
        
    from subscription_with_plans
)

select * from subscription_revenue
