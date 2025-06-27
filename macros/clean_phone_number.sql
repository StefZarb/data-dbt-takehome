{% macro clean_phone_number(phone_column) %}
    case 
        when {{ phone_column }} is null then null
        when {{ phone_column }} = '' then null
        when {{ phone_column }} = '-' then null
        when {{ phone_column }} = 'unknown' then null
        when {{ phone_column }} = 'invalid' then null
        else {{ phone_column }}
    end
{% endmacro %} 