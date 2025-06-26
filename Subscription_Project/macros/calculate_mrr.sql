--# macros/calculate_mrr.sql

{% macro calculate_mrr(plan_price_monthly, plan_price_annual, billing_cycle, user_count) %}
    case 
        when {{ billing_cycle }} = 'monthly' then {{ plan_price_monthly }} * {{ user_count }}
        else ({{ plan_price_annual }} * {{ user_count }}) / 12.0
    end
{% endmacro %}