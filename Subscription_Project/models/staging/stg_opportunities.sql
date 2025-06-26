--# models/staging/stg_opportunities.sql
{{ config(materialized='view') }}

select
    opportunity_id,
    customer_id,
    opportunity_name,
    stage as opportunity_stage,
    lead_source,
    deal_value,
    probability as close_probability,
    created_date::date as opportunity_created_date,
    close_date::date as opportunity_close_date,
    sales_rep,
    
    -- Derived fields
    case when stage in ('Closed Won', 'Closed Lost') then true else false end as is_closed,
    case when stage = 'Closed Won' then true else false end as is_won,
    case when close_date is not null and close_date <= current_date then true else false end as is_past_close_date,
    
    current_timestamp as _loaded_at
from {{ source('raw_ts', 'opportunities') }}