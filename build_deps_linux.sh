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

# Defaults to clang if CXX/CC is not found
CXX=${CXX:-$(which clang++)}
CC=${CC:-$(which clang)}

# Defaults to gcc if clang or CXX/CC is not found
CXX=${CXX:-$(which clang++)}
CC=${CC:-$(which clang)}

# Build directory
BUILD_DIR=${BUILD_DIR:-$PWD}

# Release defaults to "default"
RELEASE=${RELEASE:-"default"}
OPSYS="${OPSYS:-$(uname -o)}"
OPSYS="${OPSYS//\//_}"
RELEASE="${RELEASE//\//_}"

# Install directory defaults to under the build directory
INSTALL_DIR=${INSTALL_DIR:-"$BUILD_DIR/install-$OPSYS-$RELEASE"}

# Cache directory defaults to under the install directory
CACHE_DIR=${CACHE_DIR:-"$INSTALL_DIR/deps-cache"}

source "$SCRIPT_DIR/build_tools.sh"

if [ -f "$SCRIPT_DIR/$OPSYS/versions-$RELEASE.sh" ]; then
    source "$SCRIPT_DIR/$OPSYS/versions-$RELEASE.sh"
else
    source "$SCRIPT_DIR/$OPSYS/versions.sh"
fi

source "$SCRIPT_DIR/$OPSYS/bootstrap.sh"
source "$SCRIPT_DIR/$OPSYS/recipes.sh"

# Default number of jobs is equal to the number of processors
NUMJOBS=${NUMJOBS:-$NUMPROCS}

echo "BUILD DIR: $BUILD_DIR"
echo "INSTALL DIR: ${INSTALL_DIR}"
echo "CACHE DIR: $CACHE_DIR"
echo "NUMJOBS: $NUMJOBS"

# Makes directories if they don't exist yet
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$CACHE_DIR"

#set -euxo pipefail 
cd $BUILD_DIR
if [ -f "$SCRIPT_DIR/$OPSYS/script-$RELEASE.sh" ]; then
    source "$SCRIPT_DIR/$OPSYS/script-$RELEASE.sh"
else
    source "$SCRIPT_DIR/$OPSYS/script.sh"
fi

echo "Sources were installed on ${INSTALL_DIR}"
