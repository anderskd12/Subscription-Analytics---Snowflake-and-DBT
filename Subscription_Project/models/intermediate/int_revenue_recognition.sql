-- models/intermediate/int_revenue_recognition.sql
-- Revenue recognition calculations for GAAP compliance
{{ config(materialized='table') }}

with invoice_revenue_periods as (
    select
        i.*,
        s.billing_frequency,
        s.subscription_start_date,
        
        -- Revenue recognition period
        case 
            when s.billing_frequency = 'monthly' then 1
            else 12
        end as revenue_recognition_months,
        
        -- Monthly revenue amount
        i.final_amount / case 
            when s.billing_frequency = 'monthly' then 1
            else 12
        end as monthly_revenue_amount
        
    from {{ ref('stg_invoices') }} i
    join {{ ref('stg_subscriptions') }} s
        on i.subscription_id = s.subscription_id
),

-- Generate monthly revenue recognition entries
monthly_revenue_recognition as (
    select
        invoice_id,
        subscription_id,
        customer_id,
        billing_period_start,
        billing_period_end,
        final_amount as total_invoice_amount,
        monthly_revenue_amount,
        revenue_recognition_months,
        
        -- Generate series of months for revenue recognition
        dateadd('month', month_offset, billing_period_start) as revenue_month,
        monthly_revenue_amount as recognized_revenue
        
    from invoice_revenue_periods
    cross join (
        select 0 as month_offset union all select 1 union all select 2 union all select 3 union all
        select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all
        select 9 union all select 10 union all select 11
    ) months
    where month_offset < revenue_recognition_months
        and dateadd('month', month_offset, billing_period_start) <= billing_period_end
),

-- Add deferred revenue calculations
revenue_with_deferrals as (
    select
        *,
        total_invoice_amount - (recognized_revenue * revenue_recognition_months) as deferred_revenue_remaining,
        case 
            when revenue_month <= current_date then recognized_revenue
            else 0
        end as revenue_recognized_to_date,
        case 
            when revenue_month > current_date then recognized_revenue
            else 0
        end as deferred_revenue
    from monthly_revenue_recognition
)

select * from revenue_with_deferrals
