{% import "makina-states/services/monitoring/circus/macros.jinja" as circus with context %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-states.services.monitoring.circus

# inconditionnaly reboot circus & nginx upon deployments
/bin/true:
  cmd.run:
    - watch_in:
      - mc_proxy: circus-pre-conf

{% set circus_data = {
  'cmd': '{4}/bin/gunicorn -k {5} -t {6} -w {2} -b {0}:{1} {3}'.format(
      data.host, data.port, data.workers, data.WSGI, data.py_root, data.worker_class,
      data.worker_timeout),
  'environment': {'DJANGO_SETTINGS_MODULE': cfg.data.DJANGO_SETTINGS_MODULE},
  'uid': cfg.user,
  'gid': cfg.group,
  'copy_env': True,
  'working_dir': data.app_root,
  'warmup_delay': "10",
  'max_age': 24*60*60} %}
{{ circus.circusAddWatcher(cfg.name+'-django', **circus_data) }}
