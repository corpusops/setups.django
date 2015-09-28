{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set ds = data.django_settings %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}

{% macro set_env() %}
    - env:
      - DJANGO_SETTINGS_MODULE: "{{data.DJANGO_SETTINGS_MODULE}}"
{% endmacro %}

include:
  - makina-projects.{{cfg.name}}.include.configs

# backward compatible ID !

{{cfg.name}}-stop-all:
  cmd.run:
    - name: |
            if which nginx >/dev/null 2>&1;then
                if [ ! -d /etc/nginx/disabled ];then mkdir /etc/nginx/disabled;fi
                mv -f /etc/nginx/sites-enabled/corpus-{{cfg.name}}.conf /etc/nginx/disabled/corpus-{{cfg.name}}.conf
                service nginx restart || /bin/true;
            fi
            # circusctl can make long to answer, try 3times
            if which circusctl >/dev/null 2>&1;then
                circusctl stop {{cfg.name}}-django ||\
                ( sleep 1 && circusctl stop {{cfg.name}}-django ) ||\
                ( sleep 1 && circusctl stop {{cfg.name}}-django )
            fi
    - watch_in:
      - file: {{cfg.name}}-config
      - cmd: {{cfg.name}}-start-all

{{cfg.name}}-config:
  file.exists:
    - name: "{{data.configs['localsettings.py']['target']}}"
    - watch:
      - mc_proxy: "{{cfg.name}}-configs-post"

{% if data.get('collect_static', True) %}
static-{{cfg.name}}:
  cmd.run:
    - name: {{data.py}} manage.py collectstatic --noinput
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post

    - watch_in:
      - cmd: {{cfg.name}}-start-all
{% endif %}

{% if data.get('compile_messages', True) %}
msg-{{cfg.name}}:
  cmd.run:
    - name: {{data.py}} manage.py compilemessages
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch_in:
      - cmd: {{cfg.name}}-start-all
{% endif %}

syncdb-{{cfg.name}}:
  cmd.run:
    - name: |
            set -e
            {% if data.get('do_syncdb', True) %}
            {{data.py}} manage.py syncdb --noinput
            {% endif %}
            {% if data.get('do_migrate', True) %}
            {{data.py}} manage.py migrate --noinput
            {% endif %}
            {% if data.get('do_syncdb_only_first_time', False) %}
            touch "{{cfg.data_root}}/installed"
            {% endif %}
    {% if data.get('do_syncdb_only_first_time', False) %}
    - onlyif: test ! -e "{{cfg.data_root}}/installed"
    {% endif %}
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - use_vt: true
    - output_loglevel: info
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch_in:
      - cmd: {{cfg.name}}-start-all

{% if data.media_source != data.media %}
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
    - watch_in:
      - cmd: {{cfg.name}}-start-all
{% endif %}

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
      - mc_proxy: {{cfg.name}}-configs-post
      - cmd: syncdb-{{cfg.name}}
  cmd.run:
    - name: {{data.py}} manage.py createsuperuser --username="{{admin}}" --email="{{udata.mail}}" --noinput
    - unless: "{{f}}"
    {{set_env()}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
      - cmd: syncdb-{{cfg.name}}
      - file: user-{{cfg.name}}-{{admin}}
    - watch_in:
      - cmd: {{cfg.name}}-start-all

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
      - mc_proxy: {{cfg.name}}-configs-post
      - cmd: syncdb-{{cfg.name}}
  cmd.run:
    {{set_env()}}
    - name: {{f}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - cmd: user-{{cfg.name}}-{{admin}}
      - file: superuser-{{cfg.name}}-{{admin}}
    - watch_in:
      - cmd: {{cfg.name}}-start-all
{%endfor %}
{%endfor %}
{%endif %}

{{cfg.name}}-start-all:
  cmd.run:
    - name: |
            if which nginx >/dev/null 2>&1;then
                if [ ! -d /etc/nginx/disabled ];then mkdir /etc/nginx/disabled;fi
                mv -f /etc/nginx/disabled/corpus-{{cfg.name}}.conf /etc/nginx/sites-enabled/corpus-{{cfg.name}}.conf &&\
                service nginx restart || /bin/true;
            fi
            # circusctl can make long to answer, try 3times
            if which circusctl >/dev/null 2>&1;then
                circusctl start {{cfg.name}}-django ||\
                ( sleep 1 && circusctl start {{cfg.name}}-django ) ||\
                ( sleep 1 && circusctl start {{cfg.name}}-django )
            fi
