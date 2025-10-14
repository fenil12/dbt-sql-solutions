{% macro date_range_filter(start_date, end_date) %}
    {% if start_date and end_date %}
        WHERE ORDER_DATE BETWEEN '{{ start_date }}' AND '{{ end_date }}'
    {% elif start_date %}
        WHERE ORDER_DATE >= '{{ start_date }}'
    {% elif end_date %}
        WHERE ORDER_DATE <= '{{ end_date }}'
    {% else %}
        -- No date filter applied
    {% endif %}
{% endmacro %}