-- models/intermediate/int_customer_cohorts.sql
-- Customer cohort analysis for churn and retention
{{ config(materialized='table') }}

with customer_first_subscription as (
    select
        customer_id,
        min(subscription_start_date) as first_subscription_date,
        date_trunc('month', min(subscription_start_date)) as cohort_month
    from {{ ref('stg_subscriptions') }}
    group by customer_id
),

customer_monthly_status as (
    select
        c.customer_id,
        c.cohort_month,
        month_spine.calendar_month,
        datediff('month', c.cohort_month, month_spine.calendar_month) as period_number,
        
        -- Determine if customer was active this month
        case when s.subscription_id is not null then 1 else 0 end as is_active
        
    from customer_first_subscription c
    cross join (
        -- Generate monthly spine for the last 3 years
        select distinct date_trunc('month', subscription_start_date) as calendar_month
        from {{ ref('stg_subscriptions') }}
        where subscription_start_date >= dateadd('year', -3, current_date)
    ) month_spine
    left join {{ ref('stg_subscriptions') }} s
        on c.customer_id = s.customer_id
        and month_spine.calendar_month >= date_trunc('month', s.subscription_start_date)
        and (month_spine.calendar_month < date_trunc('month', s.subscription_end_date) 
             or s.subscription_end_date is null)
    where month_spine.calendar_month >= c.cohort_month
),

cohort_analysis as (
    select
        cohort_month,
        calendar_month,
        period_number,
        count(distinct customer_id) as total_customers,
        sum(is_active) as active_customers,
        sum(is_active)::float / count(distinct customer_id) as retention_rate
    from customer_monthly_status
    group by cohort_month, calendar_month, period_number
)

select * from cohort_analysis
