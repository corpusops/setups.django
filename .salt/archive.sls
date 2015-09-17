{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{% set db= data.django_settings.DATABASES.default %}
{% set dest = '{0}/project'.format(cfg['current_archive_dir']) %}
{{cfg.name}}-sav-project-dir:
  cmd.run:
    - name: |
            set -e
            if [ ! -d "{{dest}}" ];then
              mkdir -p "{{dest}}";
            fi;
            rsync -Aa --delete "{{cfg.project_root}}/" "{{dest}}/"
            {% if 'postgres' in db.ENGINE %}
            apt-get install -y --force-yes postgresql-client
            set +e
            export PGPASSWORD="{{db.PASSWORD}}"
            export PGUSER="{{db.USER}}"
            export PGHOST="{{db.HOST}}"
            export PGDATABASE="{{db.NAME}}"
            echo "SELECT 1 FROM pg_database WHERE datname='{{db.NAME}}';" |\
              psql postgres| grep -q 1
            if [ "x$?" = "x0" ]
            then
              pg_dump -f "{{dest}}/dump.sql"
            fi
            set -e
            {% endif %}
    - user: root
