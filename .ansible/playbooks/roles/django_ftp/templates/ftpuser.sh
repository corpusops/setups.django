#!/usr/bin/env bash
set -x
USER="{{user}}"
PASSWORD="{{password}}"
UHOME="{{home}}"
DELETE="{% if delete%}y{%endif %}"
ret=0
if [ "x$DELETE" != "x" ];then
    if ( pure-pw show "$USER" >/dev/null 2>&1 );then
        pure-pw userdel "$USER"
        ret=$?
    fi
else
    uid=$(id -u {{sysuser}})
    gid=$(getent group {{sysgroup}} | cut -d: -f3)
    f=$(mktemp)
    cat > "$f" << EOF
$PASSWORD
$PASSWORD
EOF
    pure-pw show "$USER" 2>&1 || /bin/true
    if ! ( pure-pw show "$USER" >/dev/null 2>&1 );then
      cat "$f" | pure-pw useradd "$USER" -d "$UHOME" -u $uid -g $gid -m
      ret=$?
    fi
    if ( pure-pw show "$USER" >/dev/null 2>&1 );then
      cat "$f" | pure-pw usermod "$USER" -d "$UHOME" -u $uid -g $gid -m
      ret=$?
    fi
    if [ "x$ret" != "x0" ];then
        cat "$f" | pure-pw passwd "$USER"
        ret=$?
    fi
    rm -f "${f}"
fi
exit $ret
# vim:set et sts=4 ts=4 tw=80:
