#!/usr/bin/env bash
set -x
{% if delete  %}
if ( pure-pw show "{{user}}" >/dev/null 2>&1 );then
  set -e
  pure-pw userdel "{{user}}"
fi
{% else %}
uid=$(id -u {{sysuser}})
gid=$(getent group {{sysgroup}} | cut -d: -f3)
f=$(mktemp)
echo prout $f
cat > "$f" << EOF
{{password}}
{{password}}
EOF
cat $f
echo here
pure-pw show "{{user}}" 2>&1 || /bin/true
if ! ( pure-pw show "{{user}}" >/dev/null 2>&1 );then
  set -e
  pure-pw useradd "{{user}}" -d "{{home}}" -u $uid -g $gid -m < "$f"
fi
if ( pure-pw show "{{user}}" >/dev/null 2>&1 );then
  set -e
  pure-pw usermod "{{user}}" -d "{{home}}" -u $uid -g $gid -m < "$f"
  pure-pw passwd "{{user}}" < "$f"
fi
rm -f "${f}"
{% endif %}
# vim:set et sts=4 ts=4 tw=80:
