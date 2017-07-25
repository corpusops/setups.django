#!/usr/bin/env bash
# {% set cfg = salt['mc_project.get_configuration'](cfg) %}
# {% set data = cfg.data %}
# {% set data = cfg.data %}
cd  "{{cfg.project_root}}"
a="{{data.py_root}}/bin/activate"
if [ -e "$a" ];then
    . "$a"
fi
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE-{{cfg.data.DJANGO_SETTINGS_MODULE}}}"
CLEARSESSIONS=${CLEARSESSIONS-}
NOGUNICORN=${NOGUNICORN-}
manage=
while read i;do
    if [ -e "$i" ];then
        manage=$i
        break
    fi
done < <(find */manage.py ./manage.py -type f 2>/dev/null)
if [[ ! -e $manage ]];then
    echo "No manage.py" >&2
    exit 1
fi
set -ex
if [[ -n ${CLEARSESSIONS} ]];then
    $manage clearsessions
fi
if [[ -n ${NOGUNICORN} ]];then
    exec $manage runserver {{data.runserver_args}}
fi
exec gunicorn -k {{data.worker_class}} -t {{data.worker_timeout}} \
    -w {{data.workers}} -b {{data.host}}:{{data.port}} {{data.WSGI}}
# vim:set et sts=4 ts=4 tw=80:
