#!/usr/bin/env python
import json
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
DEBUG = {%if data.DEBUG%}True{%else%}False{%endif%}
STATIC_ROOT = "{{data.static}}"
# vim:set et sts=4 ts=4 tw=80:
