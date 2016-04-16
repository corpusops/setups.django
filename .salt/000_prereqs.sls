{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set is_pg = 'postg' in data.django_settings.DATABASES.default.ENGINE %}
{% if is_pg %}
include:
  - makina-states.services.gis.ubuntugis
  - makina-states.services.db.postgresql.client
{% endif %}

prepreqs-{{cfg.name}}:
  pkg.installed:
    - watch:
      {% if is_pg %}
      - mc_proxy: ubuntugis-post-hardrestart-hook
      {% endif %}
    - pkgs:
      - sqlite3
      - liblcms2-2
      - liblcms2-dev
      - libcairomm-1.0-dev
      - libcairo2-dev
      - libsqlite3-dev
      - apache2-utils
      - autoconf
      - automake
      - build-essential
      - bzip2
      - gettext
      - libpq-dev
      - libmysqlclient-dev
      - git
      - groff
      - libbz2-dev
      - libcurl4-openssl-dev
      - libdb-dev
      - libgdbm-dev
      - libreadline-dev
      - libfreetype6-dev
      - libsigc++-2.0-dev
      - libsqlite0-dev
      - libsqlite3-dev
      - libtiff5
      - libtiff5-dev
      - libwebp5
      - libwebp-dev
      - libssl-dev
      - libtool
      - libxml2-dev
      - libxslt1-dev
      - libopenjpeg-dev
      - m4
      - man-db
      - pkg-config
      - poppler-utils
      - python-dev
      - python-imaging
      - python-setuptools
      - tcl8.4
      - tcl8.4-dev
      - tcl8.5
      - tcl8.5-dev
      - tk8.5-dev
      - cython
      - python-numpy
      - zlib1g-dev
      # geodjango
      - gdal-bin
      - libgdal1-dev
      - libgeos-dev
      - geoip-bin
      - libgeoip-dev
      # py3
      # - libpython3-dev
      # - python3
      # - python3-dev

{{cfg.name}}-dirs:
  file.directory:
    - makedirs: true
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - pkg: prepreqs-{{cfg.name}}
    - names:
      - {{cfg.data_root}}/cache
      - {{cfg.data.static}}
      - {{cfg.data.media}}
      {% if data.get('ftp_root', None) and (
            data.get('ftp_users', None) or data.get('ftp_install', False)) %}
      - {{data.ftp_root}}
      {% endif %}

{% for d, i in {
      cfg.project_root+'/cache': cfg.data_root+'/cache',
}.items() %}
{{cfg.name}}-l-dirs-{{i}}:
  file.symlink:
    - watch:
      - file: {{cfg.name}}-dirs
    - name: {{d}}
    - target: {{i}}
{%endfor %}
