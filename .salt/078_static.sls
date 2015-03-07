{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set data = cfg.data %}

{% if data.get('do_npm', False) or data.get('do_gulp', False) %}
{% set path = ('{data[app_root]}/vaultier/scripts/node_modules/.bin:'
               '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:'
               '/sbin:/bin:/usr/games:/usr/local/games').format(**cfg) %}

include:
  - makina-states.localsettings.nodejs
  - makina-states.localsettings.npm

{% macro node_run(id, require=None) %}
{{id}}:
  cmd.run:
    - watch:
      {% if require %}
      {% for i in require %}
      - {{i}}
      {%endfor%}
      {%endif%}
      - mc_proxy: nodejs-post-prefix-install
    - cwd: "{{data.js_dir}}"
    - user: {{cfg.user}}
    - unless: test ! -e "{{data.get('js_dir', '/dev/nonexisting')}}"
    - use_vt: true 
    - env:
        PATH: "{{path}}"
{% endmacro %}

{{node_run('{name}-npm'.format(**cfg))}}
    - name: npm install

{% if data.get('do_bower', False) %}
{{node_run('{name}-install-bower'.format(**cfg), ['cmd: {name}-npm'.format(**cfg)])}}
    - onlyif: test ! -e node_modules/.bin/bower
    - name: npm install bower
{{node_run('{name}-bower'.format(**cfg), ['cmd: {name}-install-bower'.format(**cfg)])}}
    - name: |
            set -e
            bower install --config.analytics=false --config.interactive=false
{% set t = ['cmd: {name}-npm'.format(**cfg)] %}

{% else %}
{% set t = ['cmd: {name}-bower'.format(**cfg)] %}
{% endif %}

{% if data.get('do_gulp', False) %}
{{node_run('{name}-gulp'.format(**cfg), t)}}
    - name: |
            set -e
            {% for i in data.get('gulp_targets', ['clean-build']) %}
            gulp {{i}}
            {% endfor %}
{% endif %}

{% else %}
{{cfg.name}}-skip:
  mc_proxy.hook: []
{% endif %}
