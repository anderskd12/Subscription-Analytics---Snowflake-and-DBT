--# models/staging/stg_subscriptions.sql
{{ config(materialized='view') }}

select
    subscription_id,
    customer_id,
    plan_id,
    billing_cycle,
    user_count,
    start_date::date as subscription_start_date,
    end_date::date as subscription_end_date,
    status as subscription_status,
    created_at::date as subscription_created_date,
    updated_at::date as subscription_updated_date,
    
    -- Derived fields
    case when end_date is null then true else false end as is_active,
    case when billing_cycle = 'monthly' then 'monthly' else 'annual' end as billing_frequency,
    
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'subscriptions') }}