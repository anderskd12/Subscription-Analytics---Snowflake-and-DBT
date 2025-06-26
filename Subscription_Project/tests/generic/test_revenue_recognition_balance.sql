-- tests/generic/test_revenue_recognition_balance.sql
-- Data validation test for revenue recognition
select
    invoice_id,
    total_invoice_amount,
    sum(recognized_revenue) as total_recognized,
    total_invoice_amount - sum(recognized_revenue) as difference
from {{ ref('int_revenue_recognition') }}
group by invoice_id, total_invoice_amount
having abs(total_invoice_amount - sum(recognized_revenue)) > 0.01