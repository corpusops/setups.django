{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set data = cfg.data %}

{% set path = ('{project_root}/node_modules/.bin:'
               '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:'
               '/sbin:/bin:/usr/games:/usr/local/games').format(**cfg) %}
{{cfg.name}}-pre-npm:
  mc_proxy.hook:
      - require_in:
        - mc_proxy: {{cfg.name}}-post-npm
{{cfg.name}}-post-npm:
  mc_proxy.hook:
    - watch_in:
        - mc_proxy: {{cfg.name}}-pre-bower
{{cfg.name}}-pre-bower:
  mc_proxy.hook:
      - require_in:
        - mc_proxy: {{cfg.name}}-post-bower
{{cfg.name}}-post-bower:
  mc_proxy.hook:
    - watch_in:
        - mc_proxy: {{cfg.name}}-pre-gulp
{{cfg.name}}-pre-gulp:
  mc_proxy.hook:
      - require:
        - mc_proxy: {{cfg.name}}-post-bower
      - require_in:
        - mc_proxy: {{cfg.name}}-post-gulp
{{cfg.name}}-post-gulp:
  mc_proxy.hook:  []

{% if ( data.get('do_node') or
        data.get('do_npm') or
        data.get('do_gulp') or
        data.get('do_bower') ) %}
include:
  - makina-states.localsettings.nodejs

{% macro node_run(id, user=cfg.user, require=None) %}
{{id}}:
  cmd.run:
    - cwd: "{{data.js_dir}}"
    - user: {{user}}
    - unless: test ! -e "{{data.get('js_dir', '/dev/nonexisting')}}"
    - use_vt: true
    - env:
        PATH: "{{path}}"

      {% if require %}
      {% for i in require %}
      - {{i}}
      {%endfor%}
      {%endif%}
    - require:
      - mc_proxy: nodejs-post-install
{% endmacro %}

{% if data.get('npm', True) %}
{{node_run('{name}-npm'.format(**cfg))}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-npm
    - require_in:
      - mc_proxy: {{cfg.name}}-post-npm
    - onlyif: test -e "{{data.js_dir}}/package.json"
    - name: |
            set -ex
            npm install
            {%if data.get('npms', None)%}
            npm install {{data.npms}}
            {%endif%}
{{node_run('{name}-global-npm'.format(**cfg), user='root')}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-npm
    - require_in:
      - mc_proxy: {{cfg.name}}-post-npm
    - onlyif: test -e "{{data.js_dir}}/package.json"
    - name: npm install -g {{data.global_npms}}
{% endif %}

{% if data.get('do_bower', False) %}
{{node_run('{name}-install-bower'.format(**cfg))}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-bower
    - onlyif: test ! -e node_modules/.bin/bower
    - name: npm install bower

{{node_run('{name}-bower'.format(**cfg))}}
    - watch:
        - cmd: {{cfg.name}}-install-bower
    - require_in:
      - mc_proxy: {{cfg.name}}-post-bower
    - onlyif: test -e "{{data.js_dir}}/bower.json"
    - name: bower install --config.analytics=false --config.interactive=false
{% endif %}

{% if data.get('do_gulp', False) %}
{{node_run('{name}-gulp'.format(**cfg))}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-gulp
    - require_in:
      - mc_proxy: {{cfg.name}}-post-gulp
    - onlyif: test -e "{{data.js_dir}}/gulpfile.js"
    - name: |
            set -e
            {% for i in data.get('gulp_targets', ['clean-build']) %}
            gulp {{i}}
            {% endfor %}
{% endif %}

{% endif %}
 
