--# models/staging/stg_invoices.sql
{{ config(materialized='view') }}

select
    invoice_id,
    subscription_id,
    customer_id,
    invoice_date::date as invoice_date,
    due_date::date as due_date,
    paid_date::date as paid_date,
    amount,
    discount_amount,
    final_amount,
    status as invoice_status,
    billing_period_start::date as billing_period_start,
    billing_period_end::date as billing_period_end,
    created_at::date as invoice_created_date,
    
    -- Derived fields
    case when paid_date is not null then true else false end as is_paid,
    case when paid_date <= due_date then true else false end as paid_on_time,
    datediff('day', invoice_date, coalesce(paid_date, current_date)) as days_to_payment,
    datediff('day', billing_period_start, billing_period_end) + 1 as billing_period_days,
    
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'invoices') }}