--# models/staging/stg_payments.sql
{{ config(materialized='view') }}

select
    payment_id,
    invoice_id,
    customer_id,
    amount as payment_amount,
    currency,
    payment_method,
    payment_date::date as payment_date,
    stripe_charge_id,
    status as payment_status,
    created_at::date as payment_created_date,
    
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'payments') }}