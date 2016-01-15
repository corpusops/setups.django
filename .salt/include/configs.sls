{% import "makina-states/_macros/h.jinja" as h with context %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

{{cfg.name}}-configs-before:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-configs-pre:
  mc_proxy.hook: []

{% macro rmacro() %}
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch:
      - mc_proxy: {{cfg.name}}-configs-pre
{% endmacro %}
{{ h.deliver_config_files(
     data.get('configs', {}),
     dir='makina-projects/{0}/files'.format(cfg.name),
     mode='750',
     user=cfg.user, group=cfg.group,
     target_prefix=data.app_root+"/",
     after_macro=rmacro, prefix=cfg.name+'-config-conf',
     project=cfg.name, cfg=cfg.name)}}

{{cfg.name}}-configs-post:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-after

{{cfg.name}}-configs-after:
  mc_proxy.hook: []
