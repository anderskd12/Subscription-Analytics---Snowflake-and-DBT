-- models/intermediate/int_churn_analysis.sql
-- Detailed churn analysis and predictions
{{ config(materialized='table') }}

with customer_subscription_timeline as (
    select
        customer_id,
        subscription_id,
        subscription_start_date,
        subscription_end_date,
        subscription_status,
        monthly_recurring_revenue,
        plan_tier,
        
        -- Churn indicators
        case when subscription_end_date is not null then 1 else 0 end as is_churned,
        datediff('day', subscription_start_date, 
                coalesce(subscription_end_date, current_date)) as tenure_days,
        
        -- Customer value at churn
        case when subscription_end_date is not null 
             then monthly_recurring_revenue * (datediff('month', subscription_start_date, subscription_end_date) + 1)
             else monthly_recurring_revenue * (datediff('month', subscription_start_date, current_date) + 1)
        end as lifetime_value
        
    from {{ ref('int_subscription_metrics') }}
),

-- Payment behavior analysis
payment_behavior as (
    select
        i.customer_id,
        i.subscription_id,
        count(*) as total_invoices,
        sum(case when i.is_paid then 1 else 0 end) as paid_invoices,
        avg(i.days_to_payment) as avg_days_to_payment,
        sum(case when not i.paid_on_time then 1 else 0 end) as late_payments,
        max(i.invoice_date) as last_invoice_date
    from {{ ref('stg_invoices') }} i
    group by i.customer_id, i.subscription_id
),

-- Usage trends
usage_trends as (
    select
        customer_id,
        subscription_id,
        count(*) as usage_months,
        avg(devices_connected) as avg_devices,
        avg(data_transfer_gb) as avg_data_transfer,
        stddev(devices_connected) as devices_volatility,
        
        -- Usage trend indicators
        case when avg(devices_connected) < 2 then 'Low Usage'
             when avg(devices_connected) < 10 then 'Medium Usage'
             else 'High Usage'
        end as usage_segment
    from {{ ref('stg_usage_data') }}
    group by customer_id, subscription_id
),

-- Combine all churn signals
churn_features as (
    select
        cst.*,
        pb.avg_days_to_payment,
        pb.late_payments,
        pb.total_invoices,
        coalesce(ut.usage_segment, 'No Usage Data') as usage_segment,
        coalesce(ut.avg_devices, 0) as avg_devices,
        
        -- Churn risk scoring
        case 
            when pb.late_payments > 2 then 3
            when pb.late_payments > 0 then 2
            else 1
        end +
        case 
            when pb.avg_days_to_payment > 30 then 2
            when pb.avg_days_to_payment > 15 then 1
            else 0
        end +
        case 
            when ut.usage_segment = 'Low Usage' then 2
            when ut.usage_segment = 'No Usage Data' then 1
            else 0
        end as churn_risk_score
        
    from customer_subscription_timeline cst
    left join payment_behavior pb
        on cst.customer_id = pb.customer_id
        and cst.subscription_id = pb.subscription_id
    left join usage_trends ut
        on cst.customer_id = ut.customer_id
        and cst.subscription_id = ut.subscription_id
)

select 
    *,
    case 
        when churn_risk_score >= 6 then 'High Risk'
        when churn_risk_score >= 4 then 'Medium Risk'
        when churn_risk_score >= 2 then 'Low Risk'
        else 'Healthy'
    end as churn_risk_category
from churn_features