{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}
{{cfg.name}}-www-data:
  user.present:
    - name: www-data
    - optional_groups:
      - {{cfg.group}}
    - remove_groups: false

prepreqs-{{cfg.name}}:
  pkg.installed:
    - watch:
      - user: {{cfg.name}}-www-data
    - pkgs:
      - nginx
      - sqlite3
      - libsqlite3-dev
      - apache2-utils
      - libcurl4-gnutls-dev

{{cfg.name}}-dirs:
  file.directory:
    - makedirs: true
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - pkg: prepreqs-{{cfg.name}}
    - names:
      - {{cfg.data_root}}/parts
      - {{cfg.data_root}}/eggs
      - {{cfg.data_root}}/cache
      - {{cfg.data.static}}

{{cfg.name}}-buildout:
  file.managed:
    - name: {{cfg.project_root}}/salt.cfg
    - source: salt://makina-projects/{{cfg.name}}/files/salt.cfg
    - template: jinja
    - user: {{cfg.user}}
    - data: |
            {{scfg}}
    - group: {{cfg.group}}
    - makedirs: true
    - watch:
      - file: {{cfg.name}}-dirs
  buildout.installed:
    - config: salt.cfg
    - name: {{cfg.project_root}}
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-buildout
    - user: {{cfg.user}}
    - group: {{cfg.group}}
