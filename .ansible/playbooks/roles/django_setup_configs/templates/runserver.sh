#!/usr/bin/env bash
# {% set data = cops_django_vars %}
cd  "{{data.project_root}}"
a="{{data.py_root}}/bin/activate"
if [ -e "$a" ];then
    . "$a"
fi
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE-{{data.DJANGO_SETTINGS_MODULE}}}"
CLEARSESSIONS=${CLEARSESSIONS-}
NOGUNICORN=${NOGUNICORN-}
DEV=${DEV-}
DEFAULT_ARGS="{{data.runserver_args}}"
#
RELOAD=${RELOAD-${DEV}}
NOTHREADING=${NOTHREADING-${DEV}}
#  dev: reload,   nothreading
# prod: noreload, threading
RS_ARGS=""
if [[ -z "${DEV}" ]];then
    if [[ -z ${RELOAD-} ]];then
        RS_ARGS="$RS_ARGS --noreload"
    fi
    if [[ -n ${NOTHREADING} ]];then
        RS_ARGS="$RS_ARGS --nothreading"
    fi
fi
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
    exec $manage runserver $RS_ARGS ${@-${DEFAULT_ARGS}}
fi
exec gunicorn \
    -k {{data.gunicorn_worker_class}} \
    -t {{data.gunicorn_worker_timeout}} \
    -w {{data.gunicorn_workers}} \
    -b {{data.django_bind_host}}:{{data.port}} \
    {{data.WSGI}}
# vim:set et sts=4 ts=4 tw=80:
