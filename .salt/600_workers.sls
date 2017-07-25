{% import "makina-states/services/monitoring/circus/macros.jinja" as circus with context %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-states.services.monitoring.circus
  - makina-projects.{{cfg.name}}.include.configs

{{cfg.name}}-workers-react-configchanges:
  mc_proxy.hook:
    - watch:
      - mc_proxy: "{{cfg.name}}-configs-after"
    - watch_in:
      - mc_proxy: "circus-post-conf-watchers"

{% set circus_data = {
  'manager_force_reload': true,
  'cmd': '{0}/runserver.sh'.format(cfg.data_root),
  'shell': false,
  'stop_children': true,
  'environment': cfg.data.environment,
  'uid': cfg.user,
  'gid': cfg.group,
  'copy_env': True,
  'working_dir': data.app_root,
  'force_restart': true,
  'warmup_delay': "10",
  'max_age': 24*60*60} %}
{{ circus.circusAddWatcher(cfg.name+'-django', **circus_data) }}
