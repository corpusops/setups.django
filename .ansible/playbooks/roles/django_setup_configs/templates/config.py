#!/usr/bin/env python
# {% set data = cops_django_vars %}
# -*- coding: utf-8 -*-
from __future__ import (print_function,
                        division,
                        absolute_import)
__docformat__ = 'restructuredtext en'

{%- macro render_setting(setting, value=None) %}
{%- set setting = setting.strip() %}
{%- if setting == 'ALLOWED_HOSTS' %}
{%-    for i in data.nginx.server_aliases %}
{%-      if i not in value %}
{%-         set _= value.append(i) %}
{%-      endif %}
{%-    endfor %}
{%- endif %}
{% if setting == 'ADMINS' %}
ADMINS = (
    {% for dadmins in data.admins -%}
    {% for admin, adata in dadmins.items() -%}
    ('{{admin}}', '{{adata.mail}}'),{# jinja indentation whitespace-#}
    {% endfor %}
    {% endfor %}
)
{% elif setting in [
    'LANGUAGES',
    'ADDITIONAL_TEMPLATE_DIRS',
] %}
{{setting}} = (
{%  for v in value -%}
        {{v-}},
{% endfor %}
)
{% elif  value|copsf_isset  or value|copsf_islist or value|copsf_isdict %}
try:
    {{setting}} = json.loads("""{{value|to_nice_json}}""".strip())
except ValueError:
    try:
        {{setting}} = json.loads("""{{value|to_json}}""".strip())
    except ValueError:
        {{setting}} = json.loads("""{{value|to_json}}""".replace('\n', '\\n').strip())
{% elif ( value|copsf_isbool or value|copsf_isnum )%}
{{-setting}} = {{value}}
{% elif value |copsf_isstr %}
{{-setting}} = """{{value}}"""
{% else %}
{{-setting}} = {{value}}
{%- endif %}
{%- endmacro %}

import json
from django.utils.translation import gettext_lazy as _
{% for setting, value in data.get('django_settings', {}).items() -%}
{{render_setting(setting, value)}}
{%- endfor %}
{% for setting, value in data.get('extra_django_settings', {}).items() -%}
{{render_setting(setting, value)}}
{%- endfor %}
{% for setting, value in data.get('extra_settings', {}).items() %}
{{setting}} = {{value}}
{% endfor %}


{{data.get('raw_settings', '')}}
# vim:set et sts=4 ts=4 tw=80:
