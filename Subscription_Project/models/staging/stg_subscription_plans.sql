--# models/staging/stg_subscription_plans.sql
{{ config(materialized='table') }}

select
    plan_id,
    plan_name,
    price_monthly,
    price_annual,
    max_devices,
    case 
        when plan_id = 'personal' then 0
        when plan_id in ('premium', 'team') then 1
        when plan_id = 'business' then 2
        when plan_id = 'enterprise' then 3
    end as plan_tier,
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'subscription_plans') }}