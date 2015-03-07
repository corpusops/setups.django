{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set ds = data.django_settings %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}

{% macro set_env() %}
    - env:
      - DJANGO_SETTINGS_MODULE: "{{data.DJANGO_SETTINGS_MODULE}}"
{% endmacro %}

{{cfg.name}}-configs:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: "{{cfg.name}}-end-configs"

{{cfg.name}}-end-configs:
  mc_proxy.hook: []

{% for i, cdata in data.get('configs', {}).items() %}
{% if not cdata.get('skip', false) %}
config-{{i}}:
  file.managed:
    - source: "salt://makina-projects/{{cfg.name}}/files/{{cdata.get('template', i)}}"
    - name: "{{cdata.get('target', '{0}/{1}'.format(cfg.project_root, i))}}"
    - template: jinja
    - mode: {{cdata.get('mode', '750')}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - mc_proxy: "{{cfg.name}}-configs"
    - watch_in:
      - mc_proxy: "{{cfg.name}}-end-configs"
    - defaults:
        cfg: "{{cfg.name}}"
{% endif %}
{% endfor %}

# backward compatible ID !
{{cfg.name}}-config:
  file.managed:
    - names:
      - "{{data.app_root}}/{{data.PROJECT}}/settings_local.py"
      - "{{data.app_root}}/{{data.PROJECT}}/local_settings.py"
      - "{{data.app_root}}/{{data.PROJECT}}/localsettings.py"
    - user: "{{cfg.user}}"
    - group: "{{cfg.group}}"
    - mode: "640"
    - watch:
      - mc_proxy: "{{cfg.name}}-configs"
      - mc_proxy: "{{cfg.name}}-end-configs"

static-{{cfg.name}}:
  cmd.run:
    - name: {{data.py}} manage.py collectstatic --noinput
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-config

{% if data.compile_messages %}
msg-{{cfg.name}}:
  cmd.run:
    - name: {{data.py}} manage.py compilemessages
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-config
{% endif %}

syncdb-{{cfg.name}}:
  cmd.run:
    #- name: {{data.py}} manage.py syncdb --noinput
    - name: {{data.py}} manage.py syncdb --noinput && {{data.py}} manage.py migrate --noinput
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

{% if data.get('create_admins', True) %}
{% for dadmins in data.admins %}
{% for admin, udata in dadmins.items() %}
{% set f = data.app_root + '/salt_' + admin + '_check.py' %}
user-{{cfg.name}}-{{admin}}:
  file.managed:
    - name: "{{f}}"
    - contents: |
                #!{{data.py}}
                import os
                try:
                    import django;django.setup()
                except Exception:
                    pass
                from {{ds.USER_MODULE}} import {{ds.USER_CLASS}} as User
                User.objects.filter(username='{{admin}}').all()[0]
                if os.path.isfile("{{f}}"):
                    os.unlink("{{f}}")
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
    - unless: "{{f}}"
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-config
      - cmd: syncdb-{{cfg.name}}
      - file: user-{{cfg.name}}-{{admin}}

{% set f = data.app_root + '/salt_' + admin + '_password.py' %}
superuser-{{cfg.name}}-{{admin}}:
  file.managed:
    - contents: |
                #!{{data.py}}
                import os
                try:
                    import django;django.setup()
                except Exception:
                    pass
                from {{ds.USER_MODULE}} import {{ds.USER_CLASS}} as User
                user=User.objects.filter(username='{{admin}}').all()[0]
                user.set_password('{{udata.password}}')
                user.email = '{{udata.mail}}'
                user.save()
                if os.path.isfile("{{f}}"):
                    os.unlink("{{f}}")
    - template: jinja
    - mode: 700
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - name: "{{f}}"
    - watch:
      - file: {{cfg.name}}-config
      - cmd: syncdb-{{cfg.name}}
  cmd.run:
    {{set_env()}}
    - name: {{f}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - cmd: user-{{cfg.name}}-{{admin}}
      - file: superuser-{{cfg.name}}-{{admin}}
{%endfor %}
{%endfor %}
{%endif %}
