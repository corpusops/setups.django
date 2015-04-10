{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

{{cfg.name}}-configs-pre:
  mc_proxy.hook: []

{% for config, tdata in data.configs.items() %}
{{cfg.name}}-{{config}}-conf:
  file.managed:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch:
      - mc_proxy: {{cfg.name}}-configs-pre
    - defaults:
        project: "{{cfg.name}}"
        cfg: "{{cfg.name}}"
    - source: {{ tdata.get(
          'source',
          'salt://makina-projects/{0}/files/{1}'.format(
           cfg.name, config))}}
    - makedirs: {{tdata.get('makedirs', True)}}
    - name: {{ tdata.get('target', '{0}/{1}'.format(
                    data.app_root, config))}}
    - user: {{tdata.get('user', cfg.user)}}
    - group: {{tdata.get('group', cfg.group)}}
    - mode: {{tdata.get('mode', 750)}}
    {% if  data.get('template', 'jinja') %}
    - template:  {{ data.get('template', 'jinja') }}
    {% endif %}
{% endfor %}

{{cfg.name}}-configs-post:
  mc_proxy.hook: []

