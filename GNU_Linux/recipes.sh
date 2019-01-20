# dependencies
#  sudo apt-get install build-essential clang automake autoconf ninja-build ccache perl

function build_package_yasm()
{
    download_tarfile "http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR}¨ " \
    build_with_configure
}

function build_package_nasm()
{
    download_tarfile "https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-${NASM_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR}¨ " \
    build_with_configure
}

function build_package_gtest()
{
    download_tarfile "https://github.com/google/googletest/archive/release-${GTEST_VERSION}.tar.gz"
    CONFIGURE_ARGS="-DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                            -DBUILD_SHARED_LIBS=ON " \
                  DIRNAME="googletest-release-${GTEST_VERSION}" \
                  PACKAGE="googletest" \
                  ENV_ARGS="PATH=$PATH:${INSTALL_DIR}/bin" build_with_cmake
}

function build_package_flex()
{
    download_tarfile "https://github.com/westes/flex/releases/download/v${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz"
    ENV_ARGS="PATH=$PATH:${INSTALL_DIR}/bin"
    build_with_configure
}

function build_package_bison()
{
    download_tarfile "http://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz"
    build_with_configure
}

function build_package_libpcap()
{
    download_tarfile "http://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz"
    ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib PATH=$PATH:${INSTALL_DIR}/bin" build_with_configure
}

function build_package_m4()
{
            download_tarfile "http://ftpmirror.gnu.org/m4/m4-${M4_VERSION}.tar.gz"
            build_with_configure
}

function build_package_libtool()
{
            download_tarfile "http://ftpmirror.gnu.org/libtool/libtool-${LIBTOOL_VERSION}.tar.gz"
            build_with_configure
}

function build_package_binutils()
{
            # http://www.linuxfromscratch.org/lfs/view/development/chapter05/binutils-pass1.html
            # http://llvm.org/docs/GoldPlugin.html
            download_tarfile "http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz"
            MACHINE="$($SCRIPT_DIR/$OPSYS/config.guess.sh)"
            ENV_ARGS="PATH=$PATH:${INSTALL_DIR}/bin"
            CONFIGURE_ARGS="./configure --enable-plugins --disable-werror --target=$MACHINE \
                            --prefix=${INSTALL_DIR}"
            MAKE_ARGS="make -j$NUMJOBS all-gold && make -j$NUMJOBS all"
            INSTALL_ARGS="make install "
            build_with_configure
}

function build_package_python()
{
            download_tarfile "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
            PYTHON_ARGS="-C  --enable-shared --enable-optimizations --enable-unicode=ucs4 \
                         --with-dbmliborder=bdb:gdbm --with-system-expat --with-computed-gotos" \
            ENV_ARGS="CFLAGS='-DNDEBUG -DPy_NDEBUG' " \
            CONFIGURE_ARGS="./configure $PYTHON_ARGS --prefix=${INSTALL_DIR}" \
                build_with_configure
}

function build_package_autoconf()
{
            download_tarfile "http://ftpmirror.gnu.org/autoconf/autoconf-${AUTOCONF_VERSION}.tar.gz"
            ENV_ARGS="PATH=$PATH:${INSTALL_DIR}/bin" build_with_configure
}

function build_package_automake()
{
            download_tarfile "http://ftpmirror.gnu.org/automake/automake-${AUTOMAKE_VERSION}.tar.gz"
            ENV_ARGS="PATH=$PATH:${INSTALL_DIR}/bin" build_with_configure
}

function build_package_cmake()
{
            CMAKE_VERSION_SHORT=$(echo $CMAKE_VERSION | cut -d '.' -f 1-2)
            #VV=(${CMAKE_VERSION//./ })
            download_tarfile "https://cmake.org/files/v${CMAKE_VERSION_SHORT}/cmake-${CMAKE_VERSION}.tar.gz"
            ENV_ARGS="PATH=$PATH:${INSTALL_DIR}/bin" build_with_configure
}

function build_package_ncurses()
{
            download_tarfile "http://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz"
            NCURSES_ARGS='--enable-shared --with-shared --with-cpp-shared'
            CONFIGURE_ARGS="CPPFLAGS=-P ./configure $NCURSES_ARGS --prefix=${INSTALL_DIR}" \
                          build_with_configure
}

function build_package_openonload()
{
            PACKAGE="openonload"
            VERSION="$OPENONLOAD_VERSION"
            DIRNAME="openonload-$OPENONLOAD_VERSION"
            EXT="tgz"
            URL="http://www.openonload.org/download/openonload-$OPENONLOAD_VERSION.tgz"
            TARFILE="openonload-$OPENONLOAD_VERSION.tgz"
            download_tarfile

            echo "PACKAGE:[$PACKAGE] VERSION:[$VERSION] URL:[$URL] EXT:[$EXT]  TARFILE:[$TARFILE]  DIRNAME:[$DIRNAME]"
            #ENV_ARGS="CPPFLAGS=\"-I$INSTALL_DIR/include\" LD_LIBRARY_PATH=${INSTALL_DIR}/lib PATH=${INSTALL_DIR}/bin:$PATH"
            ENV_ARGS="CC=$(which gcc) CFLAGS=\"-I$INSTALL_DIR/include \" LD_LIBRARY_PATH=${INSTALL_DIR}/lib PATH=${INSTALL_DIR}/bin:$PATH" \
            CONFIGURE_ARGS="true" \
            MAKE_ARGS="scripts/onload_build --user64" \
            INSTALL_ARGS="(PATH=${INSTALL_DIR}/bin:$PATH PERL5LIBS=$INSTALL_DIR/share/autoconf/Autom4te:$PERL5LIBS i_prefix=$BUILD_DIR/$DIRNAME/install_tmp scripts/onload_install \
                --userfiles --nobuild --noinstallcheck || true) && \
                rsync -av $BUILD_DIR/$DIRNAME/install_tmp/usr/ ${INSTALL_DIR}/ && \
                rsync -av $BUILD_DIR/$DIRNAME/src/include/ ${INSTALL_DIR}/include/" \
                build_with_configure
}

function build_package_ccache()
{
            download_tarfile https://www.samba.org/ftp/ccache/ccache-${CCACHE_VERSION}.tar.xz
            build_with_configure
}

function build_package_zlib()
{
            download_tarfile "http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz"
            build_with_configure
}

function build_package_libzip()
{
            download_tarfile "https://nih.at/libzip/libzip-${LIBZIP_VERSION}.tar.gz"
            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib PATH=${INSTALL_DIR}/bin:$PATH" \
                    CONFIGURE_ARGS="./configure --with-zlib=${INSTALL_DIR} --prefix=${INSTALL_DIR}" \
                    build_with_configure
}

function build_package_libxz()
{
    download_tarfile "https://downloads.sourceforge.net/project/lzmautils/xz-${LZMA_VERSION}.tar.gz"
    #download_tarfile "http://tukaani.org/xz/xz-${LZMA_VERSION}.tar.gz"
    LZMA_OPTS="--enable-shared --disable-static --disable-xzdec --disable-lzmadec --disable-xz --enable-assembler=x86_64"
    CONFIGURE_ARGS="./configure $LZMA_OPTS --prefix=${INSTALL_DIR}"\
                  INSTALL_ARGS="make install PREFIX=${INSTALL_DIR}" \
                  build_with_configure
}

function build_package_openssl()
{
            download_tarfile "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
            CONFIGURE_ARGS="./config shared no-asm -O2 --prefix=${INSTALL_DIR} --openssldir=${INSTALL_DIR}/etc" \
                          MAKE_ARGS="make depend && make -j$NUMJOBS all" \
                          build_with_configure
}

function build_package_libcurl()
{
            download_tarfile "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz"
            CURL_OPTS="--with-zlib=${INSTALL_DIR} --with-ssl=${INSTALL_DIR} --disable-dependency-tracking \
                       --disable-symbol-hiding --disable-hidden-symbols --enable-threaded-resolver \
                       --with-zsh-functions-dir=/usr/share/zsh/vendor-completions --disable-ldap \
                       --disable-ldaps --with-cyassl=${INSTALL_DIR} " \
            ENV_ARGS="CC=$MYCC CXX=$MYCXX" \
                    CONFIGURE_ARGS="./configure --with-zlib=${INSTALL_DIR} $CURL_OPTS --prefix=${INSTALL_DIR}" \
                    build_with_configure
}

function build_package_ninja()
{
    download_tarfile "https://github.com/ninja-build/ninja/archive/v${NINJA_VERSION}.tar.gz" \
                     "ninja-${NINJA_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure.py --bootstrap"
    MAKE_ARGS="true"
    INSTALL_ARGS="mkdir -p ${INSTALL_DIR}/bin && cp -v ninja ${INSTALL_DIR}/bin"
    build_with_configure
}

function build_package_sasl()
{
    (
            download_tarfile "http://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-${SASL_VERSION}.tar.gz"
            SASL_OPTS="--with-openssl=${INSTALL_DIR}/openssl --enable-plain --enable-login --enable-ntlm --with-des=no"
            ENV_ARGS="CC=$(which gcc)" \
            CONFIGURE_ARGS="./configure $SASL_OPTS --prefix=${INSTALL_DIR}" \
            build_with_configure
    )
}

function build_package_lapack()
{
            download_tarfile "http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz"
            LAPACK_OPTS="-DCMAKE_INCLUDE_PATH=${INSTALL_DIR} \
                         -DCMAKE_CXX_COMPILER=$MYCXX         \
                         -DCMAKE_C_COMPILER=$MYCC            \
                         -DCMAKE_Fortran_COMPILER=$MYFC      \
                         -DBUILD_SHARED_LIBS=ON "
            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib" CONFIGURE_ARGS="$LAPACK_OPTS" build_with_cmake
}

function build_package_openblas()
{
            # patch for clang 3.9+ assembly bug
            # clang 3.9.1 breaks OpenBLAS:  https://github.com/Homebrew/homebrew-science/issues/1010
            PACKAGE=openblas
            URL="https://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz"
            VERSION=${OPENBLAS_VERSION}
            EXT="tar.gz"
            TARFILE="OpenBLAS-${OPENBLAS_VERSION}.tar.gz"
            DIRNAME="OpenBLAS-${OPENBLAS_VERSION}"
            download_tarfile
            CONFIGURE_ARGS="( cd $BUILD_DIR/$DIRNAME; patch --verbose kernel/x86_64/dgemm_kernel_4x8_sandy.S \
                              < $SCRIPT_DIR/$OPSYS/patches/openblas_sandybridge.patch )" \
                          MAKE_ARGS="make -j$NUMJOBS PREFIX=${INSTALL_DIR} BINARY=64 DYNAMIC_ARCH=1 USE_THREADS=1 NUM_THREADS=8 CC=$MYCC" \
                          INSTALL_ARGS="make PREFIX=${INSTALL_DIR} install" \
                          build_with_configure
}

function build_package_arpack()
{
            # this we have to override names since it is non-standard
            URL="http://www.caam.rice.edu/software/ARPACK/SRC/arpack${ARPACK_VERSION}.tar.gz"
            PACKAGE="arpack"
            VERSION="${ARPACK_VERSION}"
            EXT="tar.gz"
            DIRNAME="ARPACK"
            TARFILE="arpack${ARPACK_VERSION}.tar.gz"
            download_tarfile

            CONFIGURE_ARGS="true" \
                          MAKE_ARGS="make FC=$MYCC FFLAGS=\"$FFLAGS\" MAKE=$(which make) \
           CC=${INSTALL_DIR}/bin/clang HOME=$BUILD_DIR PLAT=x86_64 all" \
                          INSTALL_ARGS="cp libarpack_x86_64.a ${INSTALL_DIR}/lib/libarpack.a "  \
                          build_with_configure
}

function build_package_tar()
{
    download_tarfile "http://ftp.gnu.org/gnu/tar/tar-${TAR_VERSION}.tar.xz"
    build_with_configure
}

function build_package_armadillo()
{
            download_tarfile "http://sourceforge.net/projects/arma/files/armadillo-${ARMADILLO_VERSION}.tar.xz"
            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib" \
            CONFIGURE_ARGS="-DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                            -DCMAKE_CXX_COMPILER=$MYCXX \
                            -DCMAKE_C_COMPILER=$MYCC \
                            -DBUILD_SHARED_LIBS=ON " \
            build_with_cmake
}

function build_package_yaml-cpp()
{
            download_tarfile "https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-${YAMLCPP_VERSION}.tar.gz"
            DIRNAME="yaml-cpp-yaml-cpp-${YAMLCPP_VERSION}"
            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib" \
            CONFIGURE_ARGS="-DCMAKE_C_FLAGS=\"$CFLAGS\" \
                            -DCMAKE_CXX_FLAGS=\"$CXXFLAGS\" \
                            -DBOOST_ROOT=\"${BUILD_DIR}/boost_${BOOST_VERSION//./_}\" \
                            -DCMAKE_CXX_COMPILER=$MYCXX \
                            -DCMAKE_C_COMPILER=$MYCC \
                            -DBUILD_SHARED_LIBS=ON \
                            -DCMAKE_PREFIX_PATH=\"${INSTALL_DIR}\" \
                            -DCMAKE_LIBRARY_PATH=\"${INSTALL_DIR}/lib\" \
                            -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}/include\" " \
            build_with_cmake
}

function build_package_cryptopp()
{
    PACKAGE=cryptopp
    DIRNAME="cryptopp_${CRYPTOPP_VERSION//./_}"
    TARFILE="$DIRNAME.tar.gz"
    VERSION="${CRYPTOPP_VERSION}"

    if [ ! -f "${CACHE_DIR}/${TARFILE}" ]; then
        rm -rf cryptopp cryptopp-cmake
        BRANCH="CRYPTOPP_${CRYPTOPP_VERSION//./_}"
        git clone -b $BRANCH https://github.com/weidai11/cryptopp.git
        git clone -b $BRANCH https://github.com/noloader/cryptopp-cmake.git
        cp "cryptopp-cmake/cryptopp-config.cmake" "cryptopp"
        cp "cryptopp-cmake/CMakeLists.txt" "cryptopp"
        rm -rf cryptopp-cmake

        # create tarball
        rm -rf "${DIRNAME}"
        mv cryptopp "${DIRNAME}"
        tar caf "${CACHE_DIR}/${TARFILE}" "${DIRNAME}"
        rm -rf "${DIRNAME}"
    fi

    ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib" \
    CONFIGURE_ARGS="-DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                    -DCMAKE_CXX_COMPILER=$MYCXX \
                    -DCMAKE_C_COMPILER=$MYCC \
                    -DBUILD_TESTING=OFF \
                    -DBUILD_SHARED_LIBS=ON" \
            build_with_cmake
}

function build_package_util-linux()
{
    (
            VV=(${UTILLINUX_VERSION//./ })
            download_tarfile "https://www.kernel.org/pub/linux/utils/util-linux/v${VV[0]}.${VV[1]}/util-linux-${UTILLINUX_VERSION}.tar.xz"
            ENV_ARGS="CFLAGS=\"-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/ncurses -O3\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib\" PATH=\"${INSTALL_DIR}/bin:$PATH\" " \
            CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} " \
            NUMJOBS=1 \
            INSTALL_ARGS="( make install; true )" \
            build_with_configure
    )
}

function build_package_aws-sdk-cpp()
{
    (
            PACKAGE="aws-sdk-cpp"
            VERSION="${AWSSDKCPP_VERSION}"
            EXT="tar.gz"
            URL="https://github.com/aws/aws-sdk-cpp/archive/${AWSSDKCPP_VERSION}.tar.gz"
            TARFILE="aws-sdk-cpp-${AWSSDKCPP_VERSION}.tar.gz"
            DIRNAME="aws-sdk-cpp-${AWSSDKCPP_VERSION}"
            download_tarfile

            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" " \
                    CONFIGURE_ARGS="-DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                                    -DCMAKE_CXX_COMPILER=$MYCXX \
                                    -DCMAKE_C_COMPILER=$MYCC  \
                                    -DBOOST_ROOT=\"${BUILD_DIR}/boost_${BOOST_VERSION//./_}\" \
                                    -DBUILD_SHARED_LIBS=ON" \
                    build_with_cmake
     )
}

function build_package_libbson()
{
            download_tarfile "https://github.com/mongodb/libbson/releases/download/${BSON_VERSION}/libbson-${BSON_VERSION}.tar.gz"
            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$LD_LIBRARY_PATH " \
                    build_with_cmake
}


function build_package_mongo-c-driver()
{
            download_tarfile "https://github.com/mongodb/mongo-c-driver/releases/download/${MONGOC_VERSION}/mongo-c-driver-${MONGOC_VERSION}.tar.gz"
            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" " \
                    CONFIGURE_ARGS="-DCMAKE_INSTALL_PREFIX=\"${INSTALL_DIR}\" \
                                    -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
                                    -DENABLE_SSL=OPENSSL \
                                    -DOPENSSL_ROOT_DIR=${INSTALL_DIR} \
                                    -DBSON_ROOT_DIR=\"${INSTALL_DIR}\" \
                                    -DCMAKE_CXX_COMPILER=$MYCXX \
                                    -DCMAKE_C_COMPILER=$MYCC \
                                    -DBUILD_SHARED_LIBS=ON " \
                    build_with_cmake
}
function build_package_mongo-cxx-driver()
{
            #https://mongodb.github.io/mongo-cxx-driver/mongocxx-v3/installation/
            download_tarfile "https://github.com/mongodb/mongo-cxx-driver/archive/r${MONGOCXX_VERSION}.tar.gz" "mongo-cxx-driver-r${MONGOCXX_VERSION}.tar.gz"
            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:$LD_LIBRARY_PATH " \
                    CONFIGURE_ARGS="-DCMAKE_INSTALL_PREFIX=\"${INSTALL_DIR}\" \
                                    -DCMAKE_C_FLAGS=\"$CFLAGS -Wall -Wextra -Wno-attributes -Werror -Wno-error=missing-field-initializers $CFLAGS\" \
                                    -DCMAKE_CXX_FLAGS=\"$CXXFLAGS -Wall -Wextra -Wno-attributes  -Wno-error=missing-field-initializers $CXXFLAGS\" \
                                    -DBOOST_ROOT=\"${BUILD_DIR}/boost_${BOOST_VERSION//./_}\" \
                                    -DLIBBSON_DIR=\"${INSTALL_DIR}\" \
                                    -DLIBMONGOC_DIR=\"${INSTALL_DIR}\" \
                                    -DBSONCXX_POLY_USE_BOOST=1 \
                                    -DCMAKE_CXX_COMPILER=$MYCXX \
                                    -DCMAKE_C_COMPILER=$MYCC \
                                    -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
                                    -DBUILD_SHARED_LIBS=ON \
                                    -DCMAKE_PREFIX_PATH=\"${INSTALL_DIR}\" \
                                    -DCMAKE_LIBRARY_PATH=\"${INSTALL_DIR}/lib\" \
                                    -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}/include\" " \
                    build_with_cmake
}

function build_package_xerces-c()
{
            download_tarfile "http://ftp.heanet.ie/mirrors/www.apache.org/dist//xerces/c/3/sources/xerces-c-${XERCESCPP_VERSION}.tar.gz"
            build_with_configure
}

function build_package_tec()
{
            git clone -b "release-${TEC_VERSION}" "https://github.com/cpc/tce.git tce-${TEC_VERSION}"

}

function build_package_wxwidgets()
{
            download_tarfile "https://github.com/wxWidgets/wxWidgets/releases/download/v${WXWIDGETS_VERSION}/wxWidgets-${WXWIDGETS_VERSION}.tar.bz2"
            build_with_configure
}

function build_package_tcl()
{
            download_tarfile "http://prdownloads.sourceforge.net/tcl/tcl${TCL_VERSION}-src.tar.gz"
            build_with_configure
}

function build_package_tbb()
{
            download_tarfile "https://github.com/01org/tbb/archive/${INTELTBB_VERSION}.tar.gz" "tbb-${INTELTBB_VERSION}.tar.gz"
            #ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$LD_LIBRARY_PATH PATH=${INSTALL_DIR}/bin:$PATH"
            CONFIGURE_ARGS="true" \
                          ENV_ARGS="PATH=${INSTALL_DIR}/bin:$PATH \
                                    CXXFLAGS=\"-fno-exceptions -I${INSTALL_DIR}/include ${CXXFLAGS}\" \
                                    CFLAGS=\"-I${INSTALL_DIR}/include ${CFLAGS}\" " \
                          MAKE_ARGS="make compiler=clang  verbose=1" \
                          INSTALL_ARGS="rsync -av --exclude='*.d' --exclude='*.o' ${BUILD_DIR}/${DIRNAME}/build/linux*_release/ ${INSTALL_DIR}/lib && \
                                        rsync -av --exclude='*.d' --exclude='*.o' ${BUILD_DIR}/${DIRNAME}/build/linux*_debug/ ${INSTALL_DIR}/lib && \
                                        mkdir -p ${INSTALL_DIR}/include/tbb && \
                                        rsync -av ${BUILD_DIR}/${DIRNAME}/include/tbb/ ${INSTALL_DIR}/include/tbb/ " \
                          build_with_configure
}

function build_package_tiny-dnn()
{
            #https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz
            download_tarfile "https://github.com/tiny-dnn/tiny-dnn/archive/v${TINYDNN_VERSION}.tar.gz" "tiny-dnn-${TINYDNN_VERSION}.tar.gz"
            ENV_ARGS="PATH=\"$PATH:${INSTALL_DIR}/bin\" LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:${INSTALL_DIR}/lib\" " \
                    CONFIGURE_ARGS="-DBUILD_SHARED_LIBS=ON \
                                    -DCMAKE_CXX_COMPILER=$MYCXX \
                                    -DUSE_OMP=ON \
                                    -DUSE_TBB=ON \
                                    -DTBB_INSTALL_DIR=${INSTALL_DIR} \
                                    -DUSE_OPENCV=OFF \
                                    -DCMAKE_C_COMPILER=$MYCC \
                                    -DCMAKE_CXX_COMPILER=$MYCXX " \
                    INSTALL_ARGS="mkdir -p ${INSTALL_DIR}/share/tiny-dnn-${TINYDNN_VERSION}/cmake/Modules && \
                                  cp -a ${BUILD_DIR}/${DIRNAME}/{test,data,examples,docs} ${INSTALL_DIR}/share/tiny-dnn-${TINYDNN_VERSION}/ && \
                                  rsync -a ${BUILD_DIR}/${DIRNAME}/cmake/Modules/ ${INSTALL_DIR}/share/tiny-dnn-${TINYDNN_VERSION}/cmake/Modules/ && \
                                  rsync -a ${BUILD_DIR}/${DIRNAME}/cereal/ ${INSTALL_DIR}/include/cereal/ && \
                                  rsync -a ${BUILD_DIR}/${DIRNAME}/third_party/ ${INSTALL_DIR}/include/third_party/  && \
                                  rsync -a ${BUILD_DIR}/${DIRNAME}/tiny_dnn/ ${INSTALL_DIR}/include/tiny_dnn/ " \
                    build_with_cmake
}

function build_package_qt5()
{
            #http://doc.qt.io/qt-5/linux-building.html
            #http://wiki.qt.io/Building_Qt_5_from_Git
            download_tarfile "http://download.qt.io/official_releases/qt/${QT_VERSION%.*}/${QT_VERSION}/single/qt-everywhere-opensource-src-${QT_VERSION}.tar.xz"
            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" " \
            CONFIGURE_ARGS="./configure \
                              -prefix ${INSTALL_DIR}/qt${QT_VERSION} \
                              -opensource -confirm-license -release -shared -ccache \
                              -no-avx -no-avx2 -c++std c++11 \
                              -skip qtsensors -skip qtlocation -skip qtconnectivity -skip qtandroidextras \
                              -skip qtx11extras -skip qtmacextras -skip qtwayland -skip qtquickcontrols \
                              -skip qtquickcontrols2 -skip qtscript -skip qtactiveqt \
                              -skip qtwebengine -skip qtwebchannel \
                              -no-opengl  \
                              -nomake examples -nomake tests  \
                              -make libs -openssl-runtime \
                              -I${INSTALL_DIR}/include \
                              -I${INSTALL_DIR}/include/openssl \
                              -L${INSTALL_DIR}/lib \
                              -platform linux-clang " \
                build_with_configure
}

function build_package_libelf()
{
    download_tarfile "http://www.mr511.de/software/libelf-${LIBELF_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static " \
      build_with_configure
}

function build_package_gmp()
{
    download_tarfile "http://gcc.gnu.org/pub/gcc/infrastructure/gmp-${GMP_VERSION}.tar.bz2"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --with-sysroot=${INSTALL_DIR} --disable-static --enable-cxx " \
      build_with_configure
}

function build_package_mpc()
{
    download_tarfile "https://gcc.gnu.org/pub/gcc/infrastructure/mpc-${MPC_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static --with-gmp=${INSTALL_DIR} --with-mpfr=${INSTALL_DIR}" \
    build_with_configure
}

function build_package_mpfr()
{
    download_tarfile "https://gcc.gnu.org/pub/gcc/infrastructure/mpfr-${MPFR_VERSION}.tar.bz2"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static --with-gmp=${INSTALL_DIR} " \
    build_with_configure
}


function build_package_gcc()
{
    #"depends": [ "binutils","libelf", "libtool", "mpc", "mpfr", "gmp", "ppl", "cloog", "isl" ],
    download_tarfile "http://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"
    ENV_ARGS="LD_LIBRARY_PATH=$INSTALL_DIR/lib:$INSTALL_DIR/lib64 \
              PATH=$INSTALL_DIR/bin:$PATH \
              LDFLAGS=\"-L${INSTALL_DIR}/lib -L${INSTALL_DIR}/lib64\" \
              CFLAGS=\"-O3 -I${INSTALL_DIR}/include\" \
              CPPFLAGS=\"-O3 -I${INSTALL_DIR}/include\" "
    CONFIGURE_ARGS="./configure \
    --prefix=${INSTALL_DIR} \
    --enable-languages=c,c++,fortran \
    --enable-threads=posix \
    --enable-tls \
    --enable-libgomp  \
    --enable-lto  \
    --disable-nls \
    --disable-checking \
    --disable-multilib \
    --disable-libstdcxx-pch \
    --with-fpmath=sse \
    --program-suffix=-${GCC_VERSION} \
    --enable-__cxa_atexit \
    --with-long-double-128 \
    --enable-secureplt \
    --with-ld=${INSTALL_DIR}/bin/ld \
    --with-as=${INSTALL_DIR}/bin/as \
    --with-gmp=${INSTALL_DIR} \
    --with-mpfr=${INSTALL_DIR} \
    --with-mpc=${INSTALL_DIR} "
    build_with_configure
}

function build_package_libpng()
{
            download_tarfile "http://prdownloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.xz"
            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" CPPFLAGS=\"$CPPFLAGS -I${INSTALL_DIR}/include \" LDFLAGS=\"-L${INSTALL_DIR}/lib\" " \
            CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --with-zlib-prefix=${INSTALL_DIR} " \
                build_with_configure
}

function build_package_libjpeg-turbo()
{
            # original https://sourceforge.net/projects/libjpeg/files/libjpeg/6b/jpegsrc.v6b.tar.gz
            download_tarfile "https://sourceforge.net/projects/libjpeg-turbo/files/${LIBJPEGTURBO_VERSION}/libjpeg-turbo-${LIBJPEGTURBO_VERSION}.tar.gz"
            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" " \
            CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} " \
            build_with_configure
}

function build_package_libjpeg()
{
            download_tarfile "https://sourceforge.net/projects/libjpeg/files/libjpeg/${LIBJPEG_VERSION}/jpegsrc.v${LIBJPEG_VERSION}.tar.gz"
            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" " \
            CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} " \
            build_with_configure
}

function build_package_freetype()
{
            download_tarfile "https://sourceforge.net/projects/freetype/files/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz"
            ENV_ARGS="PATH=\"${INSTALL_DIR}/bin:$PATH\" LD_LIBRARY_PATH=\"${INSTALL_DIR}/lib:$LD_LIBRARY_PATH\" " \
            CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} " \
            build_with_configure
}

function build_package_jsoncpp()
{
            download_tarfile "https://github.com/open-source-parsers/jsoncpp/archive/${JSONCPP_VERSION}.tar.gz" "jsoncpp-${JSONCPP_VERSION}.tar.gz"

            ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$LD_LIBRARY_PATH " \
                    build_with_cmake
}

function build_package_double-conversion()
{
            download_tarfile "https://github.com/google/double-conversion/archive/v${DOUBLECONVERSION_VERSION}.tar.gz" "double-conversion-${DOUBLECONVERSION_VERSION}.tar.gz"
            build_with_cmake
}

function build_package_libxrender()
{
            download_tarfile https://www.x.org/archive//individual/lib/libXrender-${LIBXRENDER_VERSION}.tar.gz
            build_with_configure
}

function build_package_libx11()
{
            download_tarfile https://www.x.org/archive//individual/lib/libX11-${LIBX11_VERSION}.tar.gz
            build_with_configure
}

function build_package_libxext()
{
            download_tarfile https://www.x.org/archive//individual/lib/libXext-${LIBXEXT_VERSION}.tar.gz
            build_with_configure
}

function build_package_libxfixes()
{
            download_tarfile https://www.x.org/archive//individual/lib/libXfixes-${LIBXFIXES_VERSION}.tar.gz
            build_with_configure
}

function build_package_libxi()
{
            download_tarfile https://www.x.org/archive//individual/lib/libXi-${LIBXI_VERSION}.tar.gz
            build_with_configure
}

function build_package_libxcb()
{
            https://xcb.freedesktop.org/dist/libxcb-${LIBXCB_VERSION}.tar.gz
            build_with_configure
}
