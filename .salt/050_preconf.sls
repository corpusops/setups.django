{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}

include:
  - makina-projects.{{cfg.name}}.include.configs

{% if data.app_url %}
{{cfg.name}}-download:
{% if data.app_url_type == 'git' %}
  mc_git.latest:
    - rev: "{{data.app_url_rev}}"
    - name: "{{data.app_url}}"
    - target: "{{data.app_download_dir}}"
    - user: "{{cfg.user}}"
    - watch_in:
      - mc_proxy: "{{cfg.name}}-end-download"
{% else %}
  archive.extracted:
    - source: "{{data.app_url}}"
    - source_hash: "{{data.app_url_hash}}"
    - name: "{{data.app_download_root}}"
    - archive_format: "{{data.app_url_archive_format}}"
    - tar_options: "{{data.app_url_tar_opts}}"
    - user: "{{cfg.user}}"
    - group: "{{cfg.group}}"
    - onlyif: '{{data.app_archive_test_exists}}'
    - watch_in:
      - mc_proxy: "{{cfg.name}}-end-download"
{% endif %}
{% endif %}

{{cfg.name}}-end-download:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-before
