#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import (print_function,
                        division,
                        absolute_import)
__docformat__ = 'restructuredtext en'
{%- set cfg = salt['mc_project.get_configuration'](cfg) %}
{%- set data = cfg.data %}

{%- macro render_setting(setting, value=None) %}
{%- set setting = setting.strip() %}
{%- if setting == 'ALLOWED_HOSTS' %}
{%-    for i in data.server_aliases %}
{%-      if i not in value %}
{%-         do value.append(i) %}
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
{% elif salt['mc_utils.is_a_set'](value)
      or salt['mc_utils.is_a_list'](value)
      or salt['mc_utils.is_a_dict'](value) %}
try:
    {{setting}} = json.loads("""{{salt['mc_utils.json_dump'](value, pretty=True)}}""".strip())
except ValueError:
    try:
        {{setting}} = json.loads("""{{salt['mc_utils.json_dump'](value)}}""".strip())
    except ValueError:
        {{setting}} = json.loads("""{{salt['mc_utils.json_dump'](value)}}""".replace('\n', '\\n').strip())
{% elif (
    salt['mc_utils.is_a_bool'](value)
    or salt['mc_utils.is_a_number'](value)
)%}
{{-setting}} = {{value}}
{% elif salt['mc_utils.is_a_str'](value) %}
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
# vim:set et sts=4 ts=4 tw=80:
