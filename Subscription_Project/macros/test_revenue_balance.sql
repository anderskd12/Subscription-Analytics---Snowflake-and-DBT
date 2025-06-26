--# macros/test_revenue_balance.sql

{% macro test_revenue_balance(model, invoice_amount_column, recognized_revenue_column) %}

    select
        invoice_id,
        {{ invoice_amount_column }} as invoice_amount,
        sum({{ recognized_revenue_column }}) as total_recognized,
        abs({{ invoice_amount_column }} - sum({{ recognized_revenue_column }})) as difference
    from {{ model }}
    group by invoice_id, {{ invoice_amount_column }}
    having abs({{ invoice_amount_column }} - sum({{ recognized_revenue_column }})) > 0.01

{% endmacro %}