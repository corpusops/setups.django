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
export COPS_ROOT="${COPS_ROOT:-/srv/corpusops/corpusops.bootstrap}"
DEFAULT_ANSIBLE_CWD="$(dirname "$(readlink -f "${0}")")"
export ANSIBLE_CWD="${ANSIBLE_CWD-${DEFAULT_ANSIBLE_CWD}}"
DEFAULT_A_VAULTS_FOLDERS="$ANSIBLE_CWD/.ansible/vaults $ANSIBLE_CWD/local /setup"
export ANSIBLE_ARGS="${ANSIBLE_ARGS-"-v"}"
export ANSIBLE_VARARGS="${ANSIBLE_VARARGS-}"
export A_VAULTS_FOLDERS="${A_VAULTS_FOLDERS-$DEFAULT_A_VAULTS_FOLDERS}"
if [[ -n "${A_VAULTS-}" ]];then
    export A_VAULTS="${A_VAULTS-}"
fi
export A_EXTRA_VAULTS=${A_EXTRA_VAULTS:-$@}
export ANSIBLE_PLAY="${ANSIBLE_PLAY-{{d.ep_playbook}}}"
for lca in \
    "$ANSIBLE_CWD/.ansible/scripts/call_ansible.sh"  \
    "$COPS_ROOT/bin/cops_apply_role"
do
    if [ -e "$lca" ];then
        DEFAULT_COPS_ANSIBLE_CALLER="$lca"
        break
    fi
done
if [[ -z "${DEFAULT_COPS_ANSIBLE_CALLER-}" ]];then
    echo "ansbile wrapper not found"
    exit 1
fi
COPS_ANSIBLE_CALLER="${COPS_ANSIBLE_CALLER:-$DEFAULT_COPS_ANSIBLE_CALLER}"
if [[ -n $ANSIBLE_CWD ]];then cd "$ANSIBLE_CWD";fi
if [[ -n "${A_ENV_NAME}" ]] && [ -e .ansible/scripts/setup_vaults.sh ];then
    .ansible/scripts/setup_vaults.sh
fi
if [[ -z ${NO_CONFIG-} ]];then
    $COPS_ANSIBLE_CALLER $ANSIBLE_ARGS $ANSIBLE_VARARGS $ANSIBLE_PLAY
fi
