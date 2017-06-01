{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set data = cfg.data %}
{% set npm_installer = data.get('npm_installer', 'yarn') %}
{% set use_vt = data.get('use_vt', True) %}

{% set path = ('{project_root}/node_modules/.bin:'
               '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:'
               '/sbin:/bin:/usr/games:/usr/local/games').format(**cfg) %}
{{cfg.name}}-pre-npm:
  mc_proxy.hook:
      - require_in:
        - mc_proxy: {{cfg.name}}-post-npm
{{cfg.name}}-pre-manual-npm:
  mc_proxy.hook:
      - require:
        - mc_proxy: {{cfg.name}}-pre-npm
      - require_in:
        - mc_proxy: {{cfg.name}}-post-manual-npm
{{cfg.name}}-post-manual-npm:
  mc_proxy.hook:
    - watch_in:
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
    - use_vt: {{use_vt}}
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

{% if data.get('do_npm', data.get('npm', True)) %}
{%if data.get('npms', None)%}
{{node_run('{name}-manual-npm'.format(**cfg))}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-manual-npm
    - require_in:
      - mc_proxy: {{cfg.name}}-post-manual-npm
    - name: {{npm_installer}} install {{data.npms}}
{% endif %}
{%if data.get('global_npms', None)%}
{{node_run('{name}-global-npm'.format(**cfg), user='root')}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-manual-npm
    - require_in:
      - mc_proxy: {{cfg.name}}-post-manual-npm
    - name: {{npm_installer}} install -g {{data.global_npms}}
{% endif %}
{{node_run('{name}-npm'.format(**cfg))}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-npm
      - mc_proxy: {{cfg.name}}-post-manual-npm
    - require_in:
      - mc_proxy: {{cfg.name}}-post-npm
    - onlyif: test -e "{{data.js_dir}}/package.json" || test -e "{{data.js_dir}}/yarn.lock"
    - name: {{npm_installer}} install {{data.npm_install_args}}
{% endif %}

{% if data.get('do_bower', False) %}
{{node_run('{name}-install-bower'.format(**cfg))}}
    - require:
      - mc_proxy: {{cfg.name}}-pre-bower
    - onlyif: test ! -e node_modules/.bin/bower
    - name: {{npm_installer}} install bower

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

