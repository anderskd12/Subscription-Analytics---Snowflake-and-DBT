-- tests/generic/test_customer_subscription_integrity.sql
-- Ensure referential integrity between customers and subscriptions
select
    s.subscription_id,
    s.customer_id
from {{ ref('stg_subscriptions') }} s
left join {{ ref('stg_customers') }} c
    on s.customer_id = c.customer_id
where c.customer_id is null
