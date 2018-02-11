#!/usr/bin/env bash
# {{ansible_managed}}
# {% set d = cops_django_vars %}
set -ex

WHOAMI=$(whoami)
DEFAULT_HOME=$(getent passwd $WHOAMI | cut -d: -f6)
export HOME=${HOME:-${DEFAULT_HOME}}

# Usually we will use this script twice upon the image start
# - one to reconfigure files before systemd and the service start
# - a second time after init, use case is eg to create dbs after
#   services are up
# - We call every time the same ansible playbook, with different skip tags
# The trick reside to use env vars to control what the script will do
DEFAULT_ANSIBLE_VERB="{{d.reconfigure_verbosity}}"
DEFAULT_ANSIBLE_CWD="{{d.provision_dir}}"
DEFAULT_ANSIBLE_VAULTS="{{d.ep_vaults|join(' ')}}"
DEFAULT_POST_ANSIBLE_SKIP_TAGS="{{d.ep_post_start_skip_tags}}"
DEFAULT_ANSIBLE_SKIP_TAGS="{{d.ep_skip_tags}}"
export COPS_ROOT="${COPS_ROOT:-/srv/corpusops/corpusops.bootstrap}"
export ANSIBLE_VERB="${ANSIBLE_VERB-${DEFAULT_ANSIBLE_VERB}}"
export ANSIBLE_CWD="${ANSIBLE_CWD-${DEFAULT_ANSIBLE_CWD}}"
export ANSIBLE_VAULTS="${ANSIBLE_VAULTS-${DEFAULT_ANSIBLE_VAULTS}}"
export ANSIBLE_DEFAULT_VARARGS="{{d.ep_ansible_args}}"
export ANSIBLE_ARGS="${ANSIBLE_ARGS-}"
export ANSIBLE_VARARGS="${ANSIBLE_VARARGS-${ANSIBLE_DEFAULT_VARARGS}}"
export ANSIBLE_FOLDER="${ANSIBLE_FOLDER-{{d.ep_folder}}}"
export SKIP_TAGS_MODE="${SKIP_TAGS_MODE-${1:-}}"
export ANSIBLE_PLAY="${ANSIBLE_PLAY-{{d.ep_playbook}}}"
export POST_ANSIBLE_SKIP_TAGS="${POST_ANSIBLE_SKIP_TAGS-${DEFAULT_POST_ANSIBLE_SKIP_TAGS}}"
export ANSIBLE_SKIP_TAGS="${ANSIBLE_SKIP_TAGS-${DEFAULT_ANSIBLE_SKIP_TAGS}}"
case $SKIP_TAGS_MODE in
    post)
        export ANSIBLE_SKIP_TAGS="${POST_ANSIBLE_SKIP_TAGS}";;
    *)
        export ANSIBLE_SKIP_TAGS="${ANSIBLE_SKIP_TAGS}";;
esac
for i in $ANSIBLE_VAULTS;do
    if [ -e $i ];then
        ANSIBLE_VARARGS="${ANSIBLE_VARARGS} -e @$i"
    fi
done
export ANSIBLE_VARARGS
if [[ -z ${NO_CONFIG-} ]];then
    if [[ -n $ANSIBLE_CWD ]];then
        cd "$ANSIBLE_CWD"
    fi
    play="$ANSIBLE_PLAY"
    if [[ -n "$ANSIBLE_FOLDER" ]] && [ -d "$ANSIBLE_FOLDER" ];then
        play="$ANSIBLE_FOLDER/$ANSIBLE_PLAY"
    fi
    $COPS_ROOT/bin/cops_apply_role \
        $ANSIBLE_ARGS \
        $ANSIBLE_VARARGS \
        $ANSIBLE_VERB \
        "$play" \
        --skip-tags=$ANSIBLE_SKIP_TAGS
fi
