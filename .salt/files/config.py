#!/usr/bin/env python
{% macro renderbool(opt)%}
{{opt}} = {%if data.get(opt, False)%}True{%else%}False{%endif%}
{% endmacro %}
import json
SERVER_EMAIL = DEFAULT_FROM_EMAIL ='root@{{cfg.fqdn}}'
{% set cfg = salt['mc_utils.json_load'](data) %}
{% set data = cfg.data %}
LANGUAGE_CODE = '{{data.LANGUAGE_CODE}}'
DATABASES = {
    'default': json.loads("""
{{salt['mc_utils.json_dump'](data.db)}}
""".strip()),
}
ADMINS = (
    {% for dadmins in data.admins %}
    {% for admin, data in dadmins.items() %}
    ('{{admin}}', '{{data.mail}}'),
    {% endfor %}
    {% endfor %}
)
{{renderbool('DEBUG') }}
STATIC_ROOT = "{{data.static}}"
# vim:set et sts=4 ts=4 tw=80:
