#!/bin/bash

#
# Parses a given URL and sets the variables assuming the canonical format
# URL = URLPATH/PACKAGE.VERSION.EXT
#
#    URL - parameter passed  eg http://ftp.gnu.org/files/neon.3.0.4.tgz
#    URLPATH - base path of the file (eg http://ftp.gnu.org/files)
#    PACKAGE - package name (eg neon)
#    VERSION - package version (eg 3.0.4)
#    EXT - extension (eg tgz)
#
function parse_url()
{
    URL="$1"
    read  URLPATH PACKAGE VERSION EXT <<< $(echo "$1" | sed "s/\(.*\)\/\(.*\)-\(.*\).\(tar.gz\|tar.xz\|tar.bz2\|tgz\)/\1 \2 \3 \4/")
}

#
# Downloads tarball from the internet. It can be called in three ways:
#
#   download_tarfile <url>           - this is when "url" is in canonical form (easier)
#                                      it sets PACKAGE VERSION EXT TARFILE DIRNAME
#
#   download_tarfile <url> <tarfile> - overrides the tar filename with the one provided (less common but it happens)
#                                      it sets PACKAGE VERSION EXT DIRNAME, while TARFILE is set to what you passed as <tarfile>
#
#   download_tarfile                 - (no paramters) this usage you have to set all vars (PACKAGE,VERSION,EXT,TARFILE,DIRNAME) before calling
#                                      for packages that follow no canonical form - pain in the ass
#
# Because some websites do not have a valid certificate, we just pass --no-check-certificate to wget for everyone
#
function download_tarfile()
{
    # Usage: download_tarfile <url>
    #    or  download_tarfile <url> <tarfile>
    cd $BUILD_DIR

    if [ $# -eq 1 ]; then
        parse_url $1
        TARFILE="${PACKAGE}-${VERSION}.${EXT}"
        DIRNAME="${PACKAGE}-${VERSION}"
    elif [ $# -eq 2 ]; then
        # first pass to get the URLPATH
        parse_url $1
        TARFILE="$2"
        read PACKAGE VERSION EXT <<< $(echo "$TARFILE" | sed "s/\(.*\)-\(.*\).\(tar.gz\|tar.xz\|tar.bz2\|tgz\)/\1 \2 \3/" )
        DIRNAME=${TARFILE%.$EXT}
    else
        # all these variables have to be set: PACKAGE  URL VERSION  EXT  TARFILE  DIRNAME
        if [ -z "$PACKAGE"  ] || [ -z "$VERSION" ] || [ -z "$URL" ] || [ -z "EXT" ] || [ -z "$TARFILE" ] || [ -z "$DIRNAME" ]; then
            echo "One of these variables are empty"
            echo "Package:[$PACKAGE] Version:[$VERSION] Url:[$URL] Extension:[$EXT] Tarfile:[$TARFILE] Dirname:[$DIRNAME]"
            exit 1
        fi
    fi

    if [ ! -e "$CACHE_DIR/$TARFILE" ]; then
        wget --no-check-certificate "$URL" -O "$CACHE_DIR/$TARFILE" || exit 1
    fi

    return 0
}


#
# Builds a package following the user configuration. This is the workhorse of all the build system
# The advantage of having such central routine is that we can get common cleanup and other boilerplate
#     all in the same place, reducing the error when implementing system wide changes
#
function build_generic()
{
    # Precondition: PACKAGE VERSION URL EXT TARFILE DIRNAME
    # Optional
    ENV_ARGS=${ENV_ARGS:-true}
    CONFIGURE_ARGS=${CONFIGURE_ARGS:-"./configure --prefix=${INSTALL_DIR}"}
    MAKE_ARGS=${MAKE_ARGS:-"make -j$NUMJOBS"}
    INSTALL_ARGS=${INSTALL_ARGS:-"make install"}

    # Mandatory
    if [ -z "$PACKAGE" ]; then
        echo "Package name is empty. Bailing out"
        exit 1
    fi
    if [ -z "$VERSION" ]; then
        echo "Version name is empty. Bailing out"
        exit 1
    fi

    if [ ! -e "${INSTALL_DIR}/${PACKAGE}.done" ]; then

        if [ -z "$DIRNAME" ]; then
            echo "Directory name is empty. Bailing out"
            exit 1
        fi
        if [ -z "$TARFILE" ]; then
            echo "Tar file name is empty. Bailing out"
            exit 1
        fi

        # create build directory
        rm -rf "$BUILD_DIR/$DIRNAME"
        tar xaf "$CACHE_DIR/$TARFILE" -C "${BUILD_DIR}"
        mkdir -p $TMPDIR
        cd $TMPDIR

        echo ">>>>>>>>>>>>> Compiling $PACKAGE $VERSION" >&2
        echo "ENV: $(echo "$ENV_ARGS" | tr -s ' ')" >&2
        echo "CONF: $(echo "$CONFIGURE_ARGS" | tr -s ' ') " >&2
        echo "MAKE: $(echo "$MAKE_ARGS" | tr -s ' ') " >&2
        echo "INST: $(echo "$INSTALL_ARGS" | tr -s ' ') " >&2
        (
            eval "$ENV_ARGS" && \
            eval "$CONFIGURE_ARGS" && \
            eval "$MAKE_ARGS" && \
            eval "$INSTALL_ARGS" && \
            echo $(date +%Y%m%d-%H%M%S) > ${INSTALL_DIR}/${PACKAGE}.done && \
            rm -rf "$BUILD_DIR/$DIRNAME"
        ) > ${BUILD_DIR}/${PACKAGE}.log 2> ${BUILD_DIR}/${PACKAGE}.err

    fi
    #echo "[$PACKAGE] [$VERSION] [$URL] [$EXT]  [$TARFILE]  [$DIRNAME]"
}

#
# Calls build_generic with common cmake build options
#
function build_with_cmake()
{
    TMPDIR=${TMPDIR:-"$BUILD_DIR/$DIRNAME/build-tmp"}
    MAKE_ARGS=${MAKE_ARGS:-"cmake --build ."}
    INSTALL_ARGS=${INSTALL_ARGS:-"cmake --build . --target install"}
    CONFIGURE_ARGS=${CONFIGURE_ARGS:-"cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=\"${INSTALL_DIR}\" -DCMAKE_BUILD_TYPE=Release ${BUILD_DIR}/${DIRNAME} " }
    build_generic $*
}

#
# Calls build_generic with common options for a typical ./configure build
#
function build_with_configure()
{
    TMPDIR=${TMPDIR:-"${BUILD_DIR}/${DIRNAME}"}
    build_generic $*
}

#
# Entry point to the build system. Typically the script will call this function with each package name
# The function will try to find a
#
function build_package()
{
    # Breaks if anything fails from now on
    (
        PACKAGE="$1"
        BUILD_GIST="$SCRIPT_DIR/$OPSYS/build-$PACKAGE.sh"
        if [ -f  "$BUILD_GIST" ]; then
            source "$BUILD_GIST"
        fi
        build_package_$PACKAGE
    ) || exit 1
}
