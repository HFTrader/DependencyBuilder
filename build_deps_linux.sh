#!/bin/bash

# Build in docker:
# docker run --cap-add NET_ADMIN -v /data:/data -t -i amazon /bin/bash
# docker ps -aq
# docker attach <image-id>
# /data/hblib/src/scripts/build_deps_linux.sh /data/hblib/docker /data/hblib/docker/install /data/hblib/cache/

SCRIPT_FILE=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_FILE)
if [ $# -lt 1 ]; then
    echo "Usage: $(basename $SCRIPT_FILE) -b <builddir>  [-i INSTALL_DIR] [-c CACHE_DIR] [-r RELEASE] [-o OS] [-j NUMJOBS]"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
    '-i')
        INSTALL_DIR=$(readlink -f "$2")
        shift
        ;;
    '-r')
        RELEASE="$2"
        shift
        ;;
    '-c')
        CACHE_DIR=$(readlink -f "$2")
        shift
        ;;
    '-o')
        OPSYS="$2"
        shift
        ;;
    '-j')
        NUMJOBS="$2"
        shift
        ;;
    '-b')
        BUILD_DIR=$(readlink -f "$2")
        shift
        ;;
    *)
        echo "Parameter not recognized: $1"
        exit 1
    ;;
    esac
    shift
done

CXX=${CXX:-$(which clang++)}
CC=${CC:-$(which clang)}
RELEASE=${RELEASE:-"default"}
OPSYS="${OPSYS:-$(uname -o)}"
OPSYS="${OPSYS//\//_}"
RELEASE="${RELEASE//\//_}"
INSTALL_DIR=${INSTALL_DIR:-"$BUILD_DIR/install-$OPSYS-$RELEASE"}
CACHE_DIR=${CACHE_DIR:-"$BUILD_DIR/cache"}

set -e
set -x

source "$SCRIPT_DIR/build/build_tools.sh" || exit 1
source "$SCRIPT_DIR/build/versions-$OPSYS-$RELEASE.sh" || exit 1
source "$SCRIPT_DIR/build/bootstrap-$OPSYS.sh" || exit 1
source "$SCRIPT_DIR/build/fallback-$OPSYS.sh" || exit 1

NUMJOBS=${NUMJOBS:-$NUMPROCS}

echo "BUILD DIR: $BUILD_DIR"
echo "INSTALL DIR: ${INSTALL_DIR}"
echo "CACHE DIR: $CACHE_DIR"
echo "NUMJOBS: $NUMJOBS"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$CACHE_DIR"

cd $BUILD_DIR

source "$SCRIPT_DIR/build/script-$OPSYS-$RELEASE.sh" || exit 1

echo "Sources were installed on ${INSTALL_DIR}"
