--# macros/get_current_month_start.sql

{% macro get_current_month_start() %}
    date_trunc('month', current_date)
{% endmacro %}