--# models/staging/stg_customers.sql
{{ config(materialized='view') }}

select
    customer_id,
    company_name,
    company_size,
    company_type,
    industry,
    country,
    created_at::date as customer_created_date,
    acquisition_channel,
    is_active as is_customer_active,
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'customers') }}