#!/usr/bin/env bash
# {{ ansible_managed }}
# {% set d = cops_django_vars %}
set -e
# set -x
BUILDDIR="${BUILDDIR:-"$(dirname $(readlink -f $0))/build"}"
PREFIX="${PREFIX:-"${w}/python"}"
PY_VER="${PY_VER:-{{d.py_full_ver}}}"
PY_URL="${PY_URL:-"https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tgz"}"
TAR="$(basename "${PY_URL}")"
DIR="$(basename "${PY_URL}" .tgz)"
DPY="${PREFIX}/bin/python"
DPIP="${PREFIX}/bin/pip"
DVENV="${PREFIX}/bin/virtualenv"
PIP_URL="${PIP_URL:-"https://bootstrap.pypa.io/get-pip.py"}"
PIP_INSTALLER="$(basename "${PIP_URL}")"

download() {
    url="$1"
    dest="${2:-$(basename ${url})}"
    if curl --version >/dev/null 2>&1;then
        curl -o "${dest}" -L -C - "$url"
    elif wget --version >/dev/null 2>&1;then
        wget -O "${dest}" -c "$url"
    else
        echo "no downloaders (wget/curl)"
        return 1
    fi
}
make_directories() {
    if [ ! -e "$BUILDDIR" ];then
        mkdir -pv "$BUILDDIR"
    fi
    if [ ! -e "$PREFIX" ];then
        mkdir -p "$PREFIX"
    fi
}
build_py() {
    make_directories
    cd "$BUILDDIR"
    download "${PY_URL}" "${TAR}"
    if [ ! -e $DIR/configure ];then
        tar xzf "$BUILDDIR/$TAR"
    fi
    cd "$DIR"
    export LDFLAGS="-Wl,-rpath,$PREFIX/lib"
    export LD_RUN_PATH="$PREFIX/lib"
    set -x
    ./configure --prefix="$PREFIX" --enable-shared --enable-unicode=ucs4
    make
    make install
    set +x
}
build_pip() {
    make_directories
    cd "$BUILDDIR"
    download "${PIP_URL}" "${PIP_INSTALLER}"
    "$DPY" "$PIP_INSTALLER"
}
build_venv() {
    make_directories
    "$DPIP" install --upgrade virtualenv
}
if ! "$DPY" --version >/dev/null 2>&1;then
    echo "+++ python build in $PREFIX"
    build_py
else
    echo "+++ $DPY in place, build skipped"
fi
if ! "$DPIP" --version >/dev/null 2>&1;then
    echo "+++ pip build in $PREFIX"
    build_pip
else
    echo "+++ $DPIP in place, build skipped"
fi
if ! "$DVENV" --version >/dev/null 2>&1;then
    echo "+++ virtualenv build in $PREFIX"
    build_venv
else
    echo "+++ $DVENV in place, build skipped"
fi
