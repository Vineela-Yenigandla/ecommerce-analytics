{% macro clean_text(column_name) %}
    nullif(trim(cast({{ column_name }} as varchar)), '')
{% endmacro %}
