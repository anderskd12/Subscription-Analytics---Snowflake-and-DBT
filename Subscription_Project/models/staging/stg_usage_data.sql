--# models/staging/stg_usage_data.sql
{{ config(materialized='view') }}

select
    usage_id,
    subscription_id,
    customer_id,
    month::date as usage_month,
    devices_connected,
    data_transfer_gb,
    active_users,
    connection_hours,
    created_at::date as usage_recorded_date,
    
    -- Derived metrics
    case when devices_connected > 0 then data_transfer_gb / devices_connected else 0 end as avg_data_per_device,
    case when active_users > 0 then connection_hours / active_users else 0 end as avg_hours_per_user,
    
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'usage_data') }}