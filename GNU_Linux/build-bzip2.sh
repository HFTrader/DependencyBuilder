function make_bzip2
{
    ${CC} ${CFLAGS} ${LDFLAGS} -o libbz2.so -shared -Wall -Winline -O3 -m64 -D_FILE_OFFSET_BITS=64 -fPIC {blocksort,huffman,crctable,randtable,compress,decompress,bzlib}.c && \
    ${CC} ${CFLAGS} ${LDFLAGS} -O3 -o bzip2 bzip2.c -L. -lbz2 && \
    ${CC} ${CFLAGS} ${LDFLAGS} -O3 -o bzip2recover bzip2recover.c
}


function install_bzip2
{
    if ( test ! -d ${INSTALL_DIR}/bin ) ; then mkdir -p ${INSTALL_DIR}/bin ; fi
    if ( test ! -d ${INSTALL_DIR}/lib ) ; then mkdir -p ${INSTALL_DIR}/lib ; fi
    if ( test ! -d ${INSTALL_DIR}/man ) ; then mkdir -p ${INSTALL_DIR}/man ; fi
    if ( test ! -d ${INSTALL_DIR}/man/man1 ) ; then mkdir -p ${INSTALL_DIR}/man/man1 ; fi
    if ( test ! -d ${INSTALL_DIR}/include ) ; then mkdir -p ${INSTALL_DIR}/include ; fi
    ( \
        cp -f bzip2 ${INSTALL_DIR}/bin/bzip2 && \
        cp -f bzip2 ${INSTALL_DIR}/bin/bunzip2 && \
        cp -f bzip2 ${INSTALL_DIR}/bin/bzcat && \
        cp -f bzip2recover ${INSTALL_DIR}/bin/bzip2recover && \
        chmod a+x ${INSTALL_DIR}/bin/bzip2 && \
        chmod a+x ${INSTALL_DIR}/bin/bunzip2 && \
        chmod a+x ${INSTALL_DIR}/bin/bzcat && \
        chmod a+x ${INSTALL_DIR}/bin/bzip2recover && \
        cp -f bzip2.1 ${INSTALL_DIR}/man/man1 && \
        chmod a+r ${INSTALL_DIR}/man/man1/bzip2.1 && \
        cp -f bzlib.h ${INSTALL_DIR}/include && \
        chmod a+r ${INSTALL_DIR}/include/bzlib.h && \
        cp -f libbz2.so ${INSTALL_DIR}/lib && \
        chmod a+r ${INSTALL_DIR}/lib/libbz2.so && \
        cp -f bzgrep ${INSTALL_DIR}/bin/bzgrep && \
        ln -s -f ${INSTALL_DIR}/bin/bzgrep ${INSTALL_DIR}/bin/bzegrep && \
        ln -s -f ${INSTALL_DIR}/bin/bzgrep ${INSTALL_DIR}/bin/bzfgrep && \
        chmod a+x ${INSTALL_DIR}/bin/bzgrep && \
        cp -f bzmore ${INSTALL_DIR}/bin/bzmore && \
        ln -s -f ${INSTALL_DIR}/bin/bzmore ${INSTALL_DIR}/bin/bzless && \
        chmod a+x ${INSTALL_DIR}/bin/bzmore && \
        cp -f bzdiff ${INSTALL_DIR}/bin/bzdiff && \
        ln -s -f ${INSTALL_DIR}/bin/bzdiff ${INSTALL_DIR}/bin/bzcmp && \
        chmod a+x ${INSTALL_DIR}/bin/bzdiff && \
        cp -f bzgrep.1 bzmore.1 bzdiff.1 ${INSTALL_DIR}/man/man1 && \
        chmod a+r ${INSTALL_DIR}/man/man1/bzgrep.1 && \
        chmod a+r ${INSTALL_DIR}/man/man1/bzmore.1 && \
        chmod a+r ${INSTALL_DIR}/man/man1/bzdiff.1 && \
        echo \".so man1/bzgrep.1\" > ${INSTALL_DIR}/man/man1/bzegrep.1 && \
        echo \".so man1/bzgrep.1\" > ${INSTALL_DIR}/man/man1/bzfgrep.1 && \
        echo \".so man1/bzmore.1\" > ${INSTALL_DIR}/man/man1/bzless.1 && \
        echo \".so man1/bzdiff.1\" > ${INSTALL_DIR}/man/man1/bzcmp.1 \
    ) || exit 1
}

function build_package_bzip2
{
    download_tarfile "https://sourceforge.net/projects/bzip2/files/bzip2-${BZIP2_VERSION}.tar.gz"
    #http://www.bzip.org/$BZIP2_VERSION/bzip2-${BZIP2_VERSION}.tar.gz
    CONFIGURE_ARGS="true" \
    MAKE_ARGS="make_bzip2" \
    INSTALL_ARGS="install_bzip2" \
        build_with_configure
}
