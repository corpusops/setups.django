{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-states.services.http.nginx

# inconditionnaly reboot circus & nginx upon deployments
/bin/true:
  cmd.run:
    - watch_in:
      - mc_proxy: nginx-pre-conf-hook

{{ nginx.virtualhost(domain=data.domain, doc_root=data.doc_root,
                     server_aliases=data.server_aliases,
                     vhost_basename='corpus-'+cfg.name,
                     loglevel=data.nginx_loglevel,
                     vh_top_source=data.nginx_upstreams,
                     vh_content_source=data.nginx_vhost,
                     project=cfg.name)}}

{% if data.get('http_users', {}) %}
{% for userrow in data.http_users %}
{% for user, passwd in userrow.items() %}
{{cfg.name}}-{{user}}-htaccess:
  webutil.user_exists:
    - name: {{user}}
    - password: {{passwd}}
    - htpasswd_file: {{data.htaccess}}
    - options: m
    - force: true
{% endfor %}
{% endfor %}
{% endif %}

{{cfg.name}}-htaccess:
  file.managed:
    - name: {{data.htaccess}}
    - source: ''
    - user: www-data
    - group: www-data
    - mode: 770
    - watch:
      - mc_proxy: nginx-post-conf-hook 
