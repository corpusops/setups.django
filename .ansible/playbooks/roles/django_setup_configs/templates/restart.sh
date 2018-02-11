#!/usr/bin/env bash
# {{ ansible_managed }}
# {% set d = cops_django_vars %}
set -x
ret=0
RESTART_MODE=${RESTART_MODE:-restart}
CONTROLLER=${CONTROLLER:-"$(which supervisorctl)"}
TO_RESTART="${TO_RESTART:-all}"
for service in $TO_RESTART;do
    $CONTROLLER $RESTART_MODE $service
    cret=$?
    if [ "x$cret" != "x0" ];then
        ret=$cret
    fi
done
exit $ret
