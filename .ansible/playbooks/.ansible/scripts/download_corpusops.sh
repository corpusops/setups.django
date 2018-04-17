#!/usr/bin/env bash
set -e
log() { echo "$@" >&2; }
vv() { log "($COPS_CWD) $@";"$@"; }
debug() { if [[ -n "${ADEBUG-}" ]];then log "$@";fi }
die_() {
    rc=${1:-1}
    shift
    if [[ -n $@ ]];then
        log $@
    fi
    exit $rc
}
die() { die_ 256 $@; }
export COPS_CWD="${COPS_CWD:-$(pwd)}"
export LOCAL_COPS_ROOT="${LOCAL_COPS_ROOT:-$COPS_CWD/local/corpusops.bootstrap}"
export COPS_ROOT="${COPS_ROOT:-$HOME/corpusops/corpusops.bootstrap}"
export SYS_COPS_ROOT=${SYS_COPS_ROOT:-/srv/corpusops/corpusops.bootstrap}
export COPS_URL="${COPS_URL:-https://github.com/corpusops/corpusops.bootstrap.git}"
export NO_SHARED_COPS="${NO_SHARED_COPS-}"
if [[ -n ${SKIP_COPS_SETUP-} ]];then
    die_ 0 "-> Skip corpusops setup"
fi
# Maintain corpusops fresh and operational
# Using system one
if [[ -z ${SKIP_COPS_FROM_SYSTEM-} ]] && [ ! -e "$LOCAL_COPS_ROOT/.git" ];then
    if [ ! -e local ];then mkdir local;fi
    if [ -e "$COPS_ROOT" ] || ( [ ! -e "$COPS_ROOT" ] && [[ -z "$NO_SHARED_COPS" ]] );then
        if [ ! -e "$COPS_ROOT" ];then
            mkdir -p "$COPS_ROOT"
        fi
        log "Reuse corpusops from user system: $COPS_ROOT"
        if [ -e local/corpusops.bootstrap ] \
           && [ ! -h local/corpusops.bootstrap ];then
                rm -rvf local/corpusops.bootstrap
        fi
        if [ ! -e local/corpusops.bootstrap ];then
            ln -sf "$COPS_ROOT" "$LOCAL_COPS_ROOT"
        fi
    elif [ "x$(whoami)" = "xroot" ];then
        if [ -e "$SYS_COPS_ROOT" ];then
            log "Reuse corpusops from system: $SYS_COPS_ROOT"
                if [ -e local/corpusops.bootstrap ] && [ ! -h local/corpusops.bootstrap ];then
                rm -rvf local/corpusops.bootstrap
            fi
            if [ ! -e local/corpusops.bootstrap ];then
                ln -sf "$SYS_COPS_ROOT" "$LOCAL_COPS_ROOT"
            fi
        fi
    fi
fi
# Using local copy in fallback
if [[ -z ${SKIP_COPS_CHECKOUT-} ]] && [ ! -e "$LOCAL_COPS_ROOT/.git" ];then
    if ! git clone "$COPS_URL" "$LOCAL_COPS_ROOT";then
        die_ 21 "Error while cloning $COPS_URL -> $LOCAL_COPS_ROOT"
    fi
else
    log "corpusops.bootstrap already there in $LOCAL_COPS_ROOT"
fi
