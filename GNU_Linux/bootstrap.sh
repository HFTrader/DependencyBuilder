

MACHINE=$(/bin/bash $SCRIPT_DIR/GNU_Linux/config.guess.sh)
MYARCH=${MYARCH:-"corei7-avx"}
MYCC=${MYCC:-"${INSTALL_DIR}/bin/clang"}
MYCXX=${MYCXX:-"${INSTALL_DIR}/bin/clang++"}
MYFC=${MYFC:-"$(which gfortran)"}
if [ -z "$MYFC" ]; then
    echo "Fortran compiler not found"
fi

CFLAGS="-O3 -m64 " #-march=$MYARCH -mtune=$MYARCH"
CXXFLAGS="-O3 -m64 " #-march=$MYARCH -mtune=$MYARCH"

HYPERTHREADED=$(sed -rn 's/flags\s+:.*\b(hta)\b.*/\1/p' /proc/cpuinfo)
NUMPROCS=$(grep processor /proc/cpuinfo | wc -l )
if [ -n "$HYPERTHREADED" ]; then
    NUMPROCS=$(expr $NUMPROCS / 2)
fi

CMAKE_BUILDER="Unix Makefiles"
if [ -n "$(which ninja)" ]; then
    if [[ "$(ninja -n 2>&1 )" =~ 'build.ninja' ]]; then
        CMAKE_BUILDER=Ninja
    fi
fi

if [ -n "$(which ccache)" ]; then
    USE_CCACHE=1
    CCACHE_PROGRAM="$(which ccache)"
fi
