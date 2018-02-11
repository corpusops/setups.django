#!/usr/bin/env bash
# {{ansible_managed}}{% set cfg = cops_django_vars %}
# Enforce {{cfg.name}} file permissions/ownerships

set +e

THIS=$(readlink -f "$0")
user="{{cfg.user}}"
group="{{cfg.group}}"
projects_dir="{{cfg.projects_dir}}"
project_dir="{{cfg.project_dir}}"
project_root="{{cfg.project_root}}"
data_root="{{cfg.data_root}}"
SUPEREDITORS="${SUPEREDITORS:-{{cfg.supereditors|join(' ')}}}"
TOP_DIRS=""
TOP_SCRIPTS="
$THIS
"
SUPEREDITORS_PATHS="
{{cfg.supereditors_paths|join('\n')}}
"
log() { echo "${@}" >&2; }
vv() { log "${@}"; "$@"; }
in_group() {
    local user=$1
    local group=$2
    groups $user 2>/dev/null\
        | sed -e "s/^[^:]\+: \+//g" | xargs -n1 2>/dev/null\
        | egrep -q "^${group}$"
    return $?
}
user_exists() { ( getent passwd $i >/dev/null 2>&1; );return $?; }

for i in "$projects_dir" "$project_dir";do
    if ( echo "$project_root" | grep -q "$i" ) && [ "x$i" != "x${project_root}" ];then
        TOP_DIRS="$TOP_DIRS
$i"
    fi
done

if ! ( getent group $group >/dev/null 2>&1 );then
    vv groupadd -r $group
fi
# hack to be sure that nginx is in www-data in most cases
for i in nginx www-data;do
    if user_exists $i && ! ( in_group $i $group; );then
        vv gpasswd -a $i $group 2>&1
    fi
done

if [[ -n $SUPEREDITORS ]];then
    echo "Supereditors mode, may this not be used in production" >&2
    echo "It's unsecure !!!" >&2
    while read i;do
        if [ -e "${i}" ] && [ ! -h "${i}" ];then
            echo "Applying USER $user:$group ACL to $i" >&2
            if [ -d "${i}" ];then
                setfacl -R \
                     -m "d:group:${group}:rwx,group:${group}:rwx" \
                     -m "d:user:${user}:rwx,user:${user}:rwx" \
                     "${i}"
            else
                setfacl \
                    -m "d:group:${group}:rwx,group:${group}:rwx" \
                    -m "d:user:${user}:rwx,user:${user}:rwx" \
                    "${i}"
            fi
            for editor in ${SUPEREDITORS};do
                echo "Applying EDITOR $editor ACL to $i" >&2
                if [ -d "${i}" ];then
                    setfacl -R -m\
                         "d:user:${editor}:rwx,user:${editor}:rwx" \
                         "${i}"
                else
                    setfacl -m "user:${editor}:rwx" "${i}"
                fi
            done
        fi
    done <<< "${SUPEREDITORS_PATHS}"
fi

while read i;do
    echo "$i"
    if [ ! -h "${i}" ];then
      if [ -d "${i}" ];then
        chmod g-s "${i}"
        chown $user:$group "${i}"
        chmod g+s "${i}"
      elif [ -f "${i}" ];then
        chown $user:$group "${i}"
      fi
    fi
done < <( \
 find -H \
    "$project_root" \
    "$data_root" \
 \(\
    \( -type f -and \( -not -user $user -or -not -group $group \) \)\
    -or \( \
       -type d -and \( -not -user $user -or \
                       -not -group $group -or \
                       -not -perm -2000 \) \
    \)\
 \) )

while read i;do
    if [ ! -e "$i" ];then continue;fi
    while read j;do
        echo $j
        chmod g+x,o+x "$j"
        chown root:root "$j"
    done < <(\
 find -H "$i" -mindepth 0 -maxdepth 0 \
 \(\
       -type d -and \( -not -user  root -or \
                       -not -group root -or \
                       -not -perm /g+x,o+x \) \
 \) )
done <<< "$TOP_DIRS"

while read i;do
    if [ ! -e "$i" ];then continue;fi
    while read j;do
        echo $j
        chmod 0755 "$j"
        chown root:root "$j"
    done < <(\
 find -H "$i" -mindepth 0 -maxdepth 0 \
 \(\
       -type f -and \( -not -user  root -or \
                       -not -group root -or \
                       -not -perm 0755 \) \
 \) )
done <<< "$TOP_SCRIPTS"
