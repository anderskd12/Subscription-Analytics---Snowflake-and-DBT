-- Validate MRR calculations are consistent
with mrr_check as (
    select
        subscription_id,
        monthly_recurring_revenue as calculated_mrr,
        case 
            when billing_frequency = 'monthly' then price_monthly * user_count
            else (price_annual * user_count) / 12.0
        end as expected_mrr
    from {{ ref('int_subscription_metrics') }}
)
select *
from mrr_check
where abs(calculated_mrr - expected_mrr) > 0.01