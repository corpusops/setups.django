{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}


{% macro set_env() %}
    - env:
      - DJANGO_SETTINGS_MODULE: "{{data.DJANGO_SETTINGS_MODULE}}"
{% endmacro %}

{{cfg.name}}-config:
  file.managed:
    - name: {{data.app_root}}/{{data.PROJECT}}/settings_local.py
    - source: salt://makina-projects/{{cfg.name}}/files/config.py
    - template: jinja
    - user: {{cfg.user}}
    - defaults:
      cfg: |
           {{scfg}}
    - group: {{cfg.group}}
    - makedirs: true

static-{{cfg.name}}:
  cmd.run:
    - name: {{data.py}} manage.py collectstatic --noinput
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-config

syncdb-{{cfg.name}}:
  cmd.run:
    - name: {{data.py}} manage.py syncdb --noinput
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - use_vt: true
    - output_loglevel: info
    - watch:
      - file: {{cfg.name}}-config

media-{{cfg.name}}:
  cmd.run:
    - name: rsync -av {{data.media_source}}/ {{data.media}}/
    - onlyif: test -e {{data.media_source}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - use_vt: true
    - output_loglevel: info
    - watch:
      - file: {{cfg.name}}-config

{% for dadmins in data.admins %}
{% for admin, udata in dadmins.items() %}
user-{{cfg.name}}-{{admin}}:
  file.managed:
    - name: "{{data.app_root}}/salt_{{admin}}_check.py"
    - contents: |
                #!{{data.py}}
                import os
                try:
                    import django;django.setup()
                except Exception:
                    pass
                from django.contrib.auth.models import User;User.objects.filter(username='{{admin}}').all()[0]
                if os.path.isfile("{{data.app_root}}/salt_{{admin}}_check.py"):
                    os.unlink("{{data.app_root}}/salt_{{admin}}_check.py")
    - mode: 700
    - template: jinja
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - source: ""
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-config
      - cmd: syncdb-{{cfg.name}}
  cmd.run:
    - name: {{data.py}} manage.py createsuperuser --username="{{admin}}" --email="{{udata.mail}}" --noinput
    - unless: "{{data.app_root}}/salt_{{admin}}_check.py"
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-config
      - cmd: syncdb-{{cfg.name}}
      - file: user-{{cfg.name}}-{{admin}}

superuser-{{cfg.name}}-{{admin}}:
  file.managed:
    - contents: |
                #!{{data.py}}
                import os
                try:
                    import django;django.setup()
                except Exception:
                    pass
                from django.contrib.auth.models import User
                user=User.objects.filter(username='{{admin}}').all()[0]
                user.set_password('{{udata.password}}')
                user.save()
                if os.path.isfile("{{data.app_root}}/salt_{{admin}}_password.py"):
                    os.unlink("{{data.app_root}}/salt_{{admin}}_password.py")
    - template: jinja
    - mode: 700
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - name: "{{data.app_root}}/salt_{{admin}}_password.py"
    - watch:
      - file: {{cfg.name}}-config
      - cmd: syncdb-{{cfg.name}}
  cmd.run:
    {{set_env()}}
    - name: {{data.app_root}}/salt_{{admin}}_password.py
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - cmd: user-{{cfg.name}}-{{admin}}
      - file: superuser-{{cfg.name}}-{{admin}}
{%endfor %}
{%endfor %}
