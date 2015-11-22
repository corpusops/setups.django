{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{# export macro to callees #}
{% set ugs = salt['mc_usergroup.settings']() %}
{% set locs = salt['mc_locations.settings']() %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{% set ftp_root = data.get('ftp_root', cfg.data_root) %}
{{cfg.name}}-restricted-perms:
  file.managed:
    - name: {{cfg.project_dir}}/global-reset-perms.sh
    - mode: 750
    - user: {% if not cfg.no_user%}{{cfg.user}}{% else -%}root{% endif %}
    - group: {{cfg.group}}
    - contents: |
            #!/usr/bin/env bash
            if [ -e "{{cfg.pillar_root}}" ];then
            "{{locs.resetperms}}" "${@}" \
              --dmode '0770' --fmode '0770' \
              --user root --group "{{ugs.group}}" \
              --users root \
              --groups "{{ugs.group}}" \
              --paths "{{cfg.pillar_root}}";
            fi
            if [ -e "{{cfg.project_root}}" ];then
              "{{locs.resetperms}}" "${@}" \
              --dmode '0770' --fmode '0770'  \
              --paths "{{cfg.project_root}}" \
              --paths "{{data.static}}" \
              --paths "{{data.media}}" \
              --paths "{{cfg.data_root}}" \
              --users www-data \
              --excludes="{{data.py_root}}/lib" \
              --excludes="{{data.py_root}}/bin" \
              --excludes="{{data.py_root}}/include" \
              --excludes="{{data.py_root}}/sbin" \
              --excludes="{{data.py_root}}/share" \
              --excludes="{{data.py_root}}/man" \
              --excludes="{{data.py_root}}/local" \
              --excludes=".*venv.*" \
              --users {% if not cfg.no_user%}{{cfg.user}}{% else -%}root{% endif %} \
              --groups {{cfg.group}} \
              --user {% if not cfg.no_user%}{{cfg.user}}{% else -%}root{% endif %} \
              --group {{cfg.group}};
              "{{locs.resetperms}}" "${@}" \
              --no-recursive -o\
              --dmode '0555' --fmode '0644'  \
              --paths "{{cfg.project_root}}" \
              --paths "{{cfg.project_dir}}" \
              --paths "{{cfg.project_dir}}"/.. \
              --paths "{{cfg.project_dir}}"/../.. \
              --users www-data ;
              {% for users in data.get('ftp_users', []) %}
              {% for user, udata in users.items()%}
              {% set sysuser = udata.get('user', user) %}
              {% set home = udata.get('home', ftp_root) %}
              {% if home.endswith('/') %}{% set home = home[:-1]%}{%endif%}
              {% set parents = home.split('/')[:-1] %}
              {% for i in range(1 + parents|length) %}
              {% set parent = '/'.join(parents[0:i]) %}
              {% if parent %}
              setfacl -m "u:{{sysuser}}:--x" "{{parent}}"
              {%endif%}
              {%endfor%}
              setfacl -R -m "u:{{sysuser}}:rwx" "{{home}}"
              setfacl -R -d -m "u:{{sysuser}}:rwx" "{{home}}"
              {% endfor %}
              {% endfor %}
              
            fi
  cmd.run:
    - name: {{cfg.project_dir}}/global-reset-perms.sh
    - cwd: {{cfg.project_root}}
    - user: root
    - watch:
      - file: {{cfg.name}}-restricted-perms
