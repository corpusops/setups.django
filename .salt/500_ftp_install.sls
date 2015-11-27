{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

{% set ftp_users = data.get('ftp_users', []) %}
{% set ftp_root = cfg.data.get('ftp_root', cfg.data_root) %}

{% if ftp_users or data.get('ftp_install', False) %}
include:
  - makina-states.services.ftp.pureftpd


{% set status = {'virtual': False} %}
{# create each user, his home and base layout #}
{% for userdef in ftp_users %}
{% for user, udata in userdef.items() %}

{% set sysuser = udata.get('user', user) %}
{% set sysgroup = udata.get('group', cfg.group) %}
{% set uhome = udata.get('home', ftp_root) %}
{% set mode=udata.get('mode', '2771') %}
{% set shell=udata.get('shell', '/bin/ftponly') %}
{% set password = udata.get('password',
         salt['mc_utils.generate_stored_password'](
          'corpus-django_web_adminftp'+cfg.name+user)) %}

{% set virtual = udata.get('virtual', user != sysuser) %}
{% set delete = udata.get('delete', udata.get('remove', False)) %}

{% if udata.get('create_home', True) %}
{{cfg.name}}-{{user}}-home:
  file.directory:
    - name: {{uhome}}
    - user: {{sysuser}}
    - group: {{sysgroup}}
    - mode: {{mode}}
    - makedirs: true
{% endif %}
{% if virtual %}
{% do status.update({'virtual': True}) %}
{{cfg.name}}-ftp-user-{{user}}-config:
  cmd.run:
    - name: |
        set -x
        {% if delete  %}
        if pure-pw show "{{user}}" >/dev/null 2>&1;then
          set -e
          pure-pw userdel "{{user}}"
        fi
        {% else %}
        uid=$(id -u {{sysuser}})
        gid=$(getent group {{sysgroup}} | cut -d: -f3)
        f=$(mktemp)
        cat > "$f" << EOF
        {{password}}
        {{password}}
        EOF
        if ! pure-pw show "{{user}}" >/dev/null 2>&1;then
          set -e
          pure-pw useradd "{{user}}" -d "{{uhome}}" -u $uid -g $gid -m < "$f"
        elif pure-pw show "{{user}}" >/dev/null 2>&1;then
          set -e
          pure-pw usermod "{{user}}" -d "{{uhome}}" -u $uid -g $gid -m < "$f"
          pure-pw passwd "{{user}}" < "$f"
        fi
        rm -f "${f}"
        {% endif %}
    - watch:
      - mc_proxy: ftpd-pre-configuration-hook
    - watch_in:
      - cmd: {{cfg.name}}-ftp-user-mkdb
      - mc_proxy: ftpd-post-configuration-hook
{% else %}
{{cfg.name}}-ftp-user-{{user}}:
  group.present:
    - name: {{sysuser}}
  user.present:
    - shell: {{shell}}
    - name: {{sysuser}}
    - password: {{password}}
    - gid: {{sysgroup}}
    - fullname: {{user}} user
    - optional_groups: []
    - home: {{uhome}}
    - remove_groups: False
    - gid_from_name: True
    - watch:
      - group: {{cfg.name}}-ftp-user-{{user}}
      - file: {{cfg.name}}-{{user}}-home
{% endif %}
{% endfor %}
{% endfor %}

{% if status.virtual %}
{{cfg.name}}-ftp-user-mkdb:
  cmd.run:
    - name: pure-pw mkdb
    - watch:
      - mc_proxy: ftpd-pre-configuration-hook
    - watch_in:
      - mc_proxy: ftpd-post-configuration-hook
{% endif %}

{% if data.get('ftp_port_range', '') %}
/etc/pure-ftpd/conf/PassivePortRange:
  file.managed:
    - makedirs: true
    - contents: {{data.ftp_port_range}}
    - watch_in:
      - mc_proxy: ftpd-post-configuration-hook
{%endif%}

{% if data.get('ftp_domain', '') %}
add-pasv-ip:
  cmd.run:
    - name: printf "\n127.0.0.1 {{data.ftp_domain}}\n" >> /etc/hosts
    - unless: grep "{{data.ftp_domain}}" /etc/hosts
    - watch_in:
      - mc_proxy: ftpd-post-configuration-hook
{% endif %}

{% set forcedip = data.get('ftp_domain', data.get('ftp_ip', ''))%}
{% if forcedip %}
/etc/pure-ftpd/conf/ForcePassiveIP:
  file.managed:
    - makedirs: true
    - contents: {{data.ftp_ip}}
    - watch_in:
      - mc_proxy: ftpd-post-configuration-hook
{% endif %}
{% else %}
{{cfg.name}}-ftp-skip:
  mc_proxy.hook: []
{% endif %}
