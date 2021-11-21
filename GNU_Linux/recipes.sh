# dependencies
#  sudo apt-get install build-essential clang automake autoconf ninja-build ccache perl

function build_package_sfml()
{
    download_tarfile "https://www.sfml-dev.org/files/SFML-${SFML_VERSION}-sources.zip" \
                     "SFML-${SFML_VERSION}.zip"
    build_with_cmake
}

function build_package_pkgconfig()
{
    download_tarfile "https://pkg-config.freedesktop.org/releases/pkg-config-${PKGCONFIG_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --with-internal-glib"
    build_with_configure
}

function build_package_pcre()
{
    download_tarfile "https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz"
    build_with_configure
}

function build_package_libedit()
{
    download_tarfile  "http://thrysoee.dk/editline/libedit-${LIBEDIT_VERSION}.tar.gz"
    CFLAGS="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/ncurses" \
    LDFLAGS="-L${INSTALL_DIR}/lib" \
        build_with_configure
}

function build_package_swig()
{
    download_tarfile "http://prdownloads.sourceforge.net/swig/swig-${SWIG_VERSION}.tar.gz"
    PCRE_CONFIG="${INSTALL_DIR}/bin/pcre-config" \
        build_with_configure
}

function build_package_expat()
{
    download_tarfile \
    "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION//\./_}/expat-${EXPAT_VERSION}.tar.gz"
    build_with_configure
}

function build_package_coreutils()
{
    download_tarfile "https://ftp.gnu.org/gnu/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz"
    build_with_configure
}

function build_package_texinfo()
{
    download_tarfile "https://ftp.gnu.org/gnu/texinfo/texinfo-${TEXINFO_VERSION}.tar.xz"
    CFLAGS="-I${INSTALL_DIR}/include" LDFLAGS="-L${INSTALL_DIR}/lib" build_with_configure
}

function build_package_yasm()
{
    download_tarfile "http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz"
    build_with_configure
}

function build_package_nasm()
{
    download_tarfile "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz"
    build_with_configure
}

function build_package_gtest()
{
    download_tarfile "https://github.com/google/googletest/archive/release-${GTEST_VERSION}.tar.gz" \
                     "googletest-release-${GTEST_VERSION}.tar.gz"
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                          -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                          -DBUILD_SHARED_LIBS=ON \
                          ${BUILD_DIR}/${DIRNAME}"
    DIRNAME="googletest-release-${GTEST_VERSION}"
    PACKAGE="googletest"
    #export PATH=$PATH:${INSTALL_DIR}/bin
    PATH=$PATH:${INSTALL_DIR}/bin \
        build_with_cmake
}

function build_package_flex()
{
    download_tarfile "https://github.com/westes/flex/releases/download/v${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz"
    #export PATH=$PATH:${INSTALL_DIR}/bin
    PATH=$PATH:${INSTALL_DIR}/bin \
        build_with_configure
}

function build_package_bison()
{
    download_tarfile "http://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz"
    PATH="$PATH:${INSTALL_DIR}/bin" build_with_configure
}

function build_package_libpcap()
{
    download_tarfile "http://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz"
    #export LD_LIBRARY_PATH=${INSTALL_DIR}/lib
    #export PATH=$PATH:${INSTALL_DIR}/bin
    LD_LIBRARY_PATH=${INSTALL_DIR}/lib \
    PATH=$PATH:${INSTALL_DIR}/bin \
        build_with_configure
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
    ENV_ARGS="export PATH=$PATH:${INSTALL_DIR}/bin"
    CONFIGURE_ARGS="./configure --enable-plugins --disable-werror --target=$MACHINE \
                    --prefix=${INSTALL_DIR}"
    MAKE_ARGS="make -j$NUMJOBS all-gold && make -j$NUMJOBS all"
    INSTALL_ARGS="make install "
    build_with_configure
}

function build_package_libxml2()
{
    download_tarfile "http://xmlsoft.org/sources/libxml2-${LIBXML2_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static --with-history --with-python=${INSTALL_DIR}/bin/python3 --with-python-install-dir=${INSTALL_DIR}/lib"
    build_with_configure
}

function build_package_libffi()
{
    download_tarfile "https://github.com/libffi/libffi/archive/refs/tags/v${LIBFFI_VERSION}.tar.gz" libffi-${LIBFFI_VERSION}.tar.gz
    CONFIGURE_ARGS="./autogen.sh && ./configure --prefix=${INSTALL_DIR}"
    PATH=$PATH:${INSTALL_DIR}/bin build_with_configure
}

function build_package_python()
{
    download_tarfile "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
    #export CFLAGS="-DNDEBUG -DPy_NDEBUG"
    #export CPPFLAGS="-I${INSTALL_DIR}/include/ncurses"
    PYTHON_ARGS="-C  \
                 --enable-shared \
                 --enable-unicode=ucs4 \
                 --with-dbmliborder=bdb:gdbm \
                 --enable-optimizations \
                 --with-ensurepip=install \
                 --with-system-ffi=no \
                 --with-ffi=${INSTALL_DIR} \
                 --with-expat=${INSTALL_DIR} \
                 --with-computed-gotos"
    CONFIGURE_ARGS="./configure $PYTHON_ARGS --prefix=${INSTALL_DIR}"
    MAKE_ARGS="make -j$NUMJOBS build_all"
    LD_LIBRARY_PATH="${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:$LD_LIBRARY_PATH" \
                   CFLAGS="-DNDEBUG -DPy_NDEBUG -I${INSTALL_DIR}/include" \
                   CPPFLAGS="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/ncurses" \
        build_with_configure
    cd ${INSTALL_DIR}
    ${INSTALL_DIR}/bin/pip3 install pip --upgrade pip
    ${INSTALL_DIR}/bin/pip3 install --upgrade Markdown Cheetah3 pygments pyaml
}

function build_package_autoconf()
{
    download_tarfile "http://ftpmirror.gnu.org/autoconf/autoconf-${AUTOCONF_VERSION}.tar.gz"
    #export PATH=$PATH:${INSTALL_DIR}/bin
    PATH=$PATH:${INSTALL_DIR}/bin \
        build_with_configure
}

function build_package_automake()
{
    download_tarfile "http://ftpmirror.gnu.org/automake/automake-${AUTOMAKE_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR}"
    PATH=$PATH:${INSTALL_DIR}/bin \
    PERL5LIB=${BUILD_DIR}/${DIRNAME} \
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR}"  \
        build_with_configure
}

function build_package_cmake()
{
    CMAKE_VERSION_SHORT=$(echo $CMAKE_VERSION | cut -d '.' -f 1-2)
    #VV=(${CMAKE_VERSION//./ })
    download_tarfile "https://cmake.org/files/v${CMAKE_VERSION_SHORT}/cmake-${CMAKE_VERSION}.tar.gz"
    OPENSSL_ROOT_DIR="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}" PATH=$PATH:${INSTALL_DIR}/bin \
        build_with_configure
}

function build_package_ncurses()
{
    download_tarfile "http://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz"
    NCURSES_ARGS='--enable-shared --with-shared --with-cpp-shared'
    CONFIGURE_ARGS="CPPFLAGS=-P ./configure $NCURSES_ARGS --prefix=${INSTALL_DIR}"
    build_with_configure
}

function build_package_openonload()
{
    PACKAGE="openonload"
    VERSION="${OPENONLOAD_VERSION}"
    DIRNAME="onload-${OPENONLOAD_VERSION}"
    TARFILE="onload-${OPENONLOAD_VERSION}.tgz"
    ZIP_FILE="openonload-${OPENONLOAD_VERSION}.zip"
    if [ ! -e "${CACHE_DIR}/${TARFILE}" ]; then
        URL="https://support-nic.xilinx.com/wp/onload?sd=SF-109585-LS-36&pe=SF-122921-DH-5"
        wget --no-check-certificate "$URL" -O "${CACHE_DIR}/${ZIP_FILE}"
	    mkdir -p ${BUILD_DIR}
	    cd ${BUILD_DIR}
	    rm -rf onload-${OPENONLOAD_VERSION}
	    unzip ${CACHE_DIR}/${ZIP_FILE}
	    mv -v ${TARFILE} ${CACHE_DIR}/${TARFILE}
    fi

    #ENV_ARGS="CPPFLAGS=\"-I$INSTALL_DIR/include\" LD_LIBRARY_PATH=${INSTALL_DIR}/lib PATH=${INSTALL_DIR}/bin:$PATH"
    CONFIGURE_ARGS="true" \
    MAKE_ARGS="scripts/onload_build --user64" \
    INSTALL_ARGS="(PATH=${INSTALL_DIR}/bin:$PATH PERL5LIBS=$INSTALL_DIR/share/autoconf/Autom4te:$PERL5LIBS \
                i_prefix=$BUILD_DIR/$DIRNAME/install_tmp scripts/onload_install \
                --userfiles --nobuild --noinstallcheck || true) && \
                rsync -av $BUILD_DIR/$DIRNAME/install_tmp/usr/ ${INSTALL_DIR}/ && \
                rsync -av $BUILD_DIR/$DIRNAME/src/include/ ${INSTALL_DIR}/include/"
    CC=$(which gcc) \
    CFLAGS="-I$INSTALL_DIR/include" \
    LD_LIBRARY_PATH=${INSTALL_DIR}/lib \
    PATH=${INSTALL_DIR}/bin:$PATH \
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
    ENV_ARGS="LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$LD_LIBRARY_PATH PATH=${INSTALL_DIR}/bin:$PATH" \
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
    CONFIGURE_ARGS="./config shared no-asm -O2 \
                    --prefix=${INSTALL_DIR}/openssl-${OPENSSL_VERSION} \
                    --openssldir=${INSTALL_DIR}/etc"
    MAKE_ARGS="make depend && make -j$NUMJOBS all"
    build_with_configure
}

function build_package_libcurl()
{
    download_tarfile "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz"
    CURL_OPTS="--with-zlib=${INSTALL_DIR} --with-ssl=${INSTALL_DIR}/openssl-${OPENSSL_VERSION} --disable-dependency-tracking \
               --disable-symbol-hiding --disable-hidden-symbols --enable-threaded-resolver \
               --with-zsh-functions-dir=/usr/share/zsh/vendor-completions --disable-ldap \
               --disable-ldaps --with-cyassl=${INSTALL_DIR} "
    CONFIGURE_ARGS="./configure --with-zlib=${INSTALL_DIR} $CURL_OPTS --prefix=${INSTALL_DIR}"
    LD_LIBRARY_PATH=${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:$LD_LIBRARY_PATH \
        build_with_configure
}

function build_package_pybind11()
{
    PACKAGE=pybind11
    DIRNAME="pybind11_${PYBIND11_VERSION}"
    TARFILE="${DIRNAME}.tar.gz"
    VERSION="${PYBIND11_VERSION}"

    cd ${BUILD_DIR}
    if [ ! -f "${CACHE_DIR}/${TARFILE}" ]; then
        rm -rf pybind11 pybind11-cmake
        BRANCH="v${PYBIND11_VERSION}"
        git clone -b $BRANCH https://github.com/pybind/pybind11.git pybind11
        rm -rf pybind11/.git

        # create tarball
        rm -rf "${DIRNAME}"
        mv pybind11 "${DIRNAME}"
        tar caf "${CACHE_DIR}/${TARFILE}" "${DIRNAME}"
        rm -rf "${DIRNAME}"
    fi

    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DCMAKE_C_COMPILER=$CC \
                    ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
}

function build_package_ninja()
{
    download_tarfile "https://github.com/ninja-build/ninja/archive/v${NINJA_VERSION}.tar.gz" \
                     "ninja-${NINJA_VERSION}.tar.gz"
    CONFIGURE_ARGS="${INSTALL_DIR}/bin/python3 ./configure.py --bootstrap"
    MAKE_ARGS="true"
    INSTALL_ARGS="mkdir -p ${INSTALL_DIR}/bin && cp -v ninja ${INSTALL_DIR}/bin"
    LD_LIBRARY_PATH="${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64" build_with_configure
}

function build_package_sasl()
{
    download_tarfile "http://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-${SASL_VERSION}.tar.gz"
    SASL_OPTS="--with-openssl=${INSTALL_DIR}/openssl --enable-plain --enable-login --enable-ntlm --with-des=no"
    CONFIGURE_ARGS="./configure $SASL_OPTS --prefix=${INSTALL_DIR}"
    build_with_configure
}

function build_package_lapack()
{
    download_tarfile "http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz"
    LAPACK_OPTS="-DCMAKE_INCLUDE_PATH=${INSTALL_DIR} \
                         -DCMAKE_CXX_COMPILER=$CXX         \
                         -DCMAKE_C_COMPILER=$CC            \
                         -DCMAKE_Fortran_COMPILER=$FC      \
                         -DBUILD_SHARED_LIBS=ON "
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    $LAPACK_OPTS ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
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

    #CONFIGURE_ARGS="( cd $BUILD_DIR/$DIRNAME; patch --verbose kernel/x86_64/dgemm_kernel_4x8_sandy.S \
        #               < $SCRIPT_DIR/$OPSYS/patches/openblas_sandybridge.patch )"
    CONFIGURE_ARGS="true"
    MAKE_ARGS="CFLAGS='-fallow-argument-mismatch' FFLAGS='-fallow-argument-mismatch' make DYNAMIC_ARCH=1 NO_WARMUP=1 BUILD_RELAPACK=0  BINARY=64  CC=gcc-${GCC_VERSION} FC=$FC"
    INSTALL_ARGS="make PREFIX=${INSTALL_DIR} install"
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

    CONFIGURE_ARGS="true"
    MAKE_ARGS="make FC=$FC CC=gcc-${GCC_VERSION} FFLAGS=\"$FFLAGS\" MAKE=$(which make) \
               HOME=$BUILD_DIR PLAT=x86_64 all"
    INSTALL_ARGS="cp libarpack_x86_64.a ${INSTALL_DIR}/lib/libarpack.a "
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
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                          -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                          -DCMAKE_CXX_COMPILER=$CXX \
                          -DCMAKE_C_COMPILER=$CC \
                          -DBUILD_SHARED_LIBS=ON \
                          ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
}

function build_package_yaml-cpp()
{
    download_tarfile "https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-${YAMLCPP_VERSION}.tar.gz"
    DIRNAME="yaml-cpp-yaml-cpp-${YAMLCPP_VERSION}"
    CONFIGURE_ARGS="cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                            -DBOOST_ROOT=\"${BUILD_DIR}/boost_${BOOST_VERSION//./_}\" \
                            -DCMAKE_C_FLAGS=\"$CFLAGS\" \
                            -DCMAKE_CXX_FLAGS=\"$CXXFLAGS\" \
                            -DCMAKE_CXX_COMPILER=$CXX \
                            -DCMAKE_C_COMPILER=$CC \
                            -DBUILD_SHARED_LIBS=ON \
			    -DYAML_CPP_BUILD_TESTS=OFF \
                            -DCMAKE_PREFIX_PATH=\"${INSTALL_DIR}\" \
                            -DCMAKE_LIBRARY_PATH=\"${INSTALL_DIR}/lib\" \
                            -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}/include\" \
                            ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
}

function build_package_cryptopp()
{
    PACKAGE=cryptopp
    DIRNAME="cryptopp_${CRYPTOPP_VERSION//./_}"
    TARFILE="$DIRNAME.tar.gz"
    VERSION="${CRYPTOPP_VERSION}"

    cd ${BUILD_DIR}
    if [ ! -f "${CACHE_DIR}/${TARFILE}" ]; then
        rm -rf cryptopp cryptopp-cmake
        BRANCH="CRYPTOPP_${CRYPTOPP_VERSION//./_}"
        git clone -b $BRANCH https://github.com/weidai11/cryptopp.git cryptopp
        git clone -b $BRANCH https://github.com/noloader/cryptopp-cmake.git
        cp "cryptopp-cmake/cryptopp-config.cmake" "cryptopp"
        cp "cryptopp-cmake/CMakeLists.txt" "cryptopp"
        rm -rf cryptopp-cmake
        rm -rf cryptopp/.git

        # create tarball
        rm -rf "${DIRNAME}"
        mv cryptopp "${DIRNAME}"
        tar caf "${CACHE_DIR}/${TARFILE}" "${DIRNAME}"
        rm -rf "${DIRNAME}"
    fi

    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}\" \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DCMAKE_C_COMPILER=$CC \
                    -DBUILD_TESTING=OFF \
                    -DBUILD_SHARED_LIBS=ON \
                    ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
}

function build_package_util-linux()
{
    VV=(${UTILLINUX_VERSION//./ })
    download_tarfile "https://www.kernel.org/pub/linux/utils/util-linux/v${VV[0]}.${VV[1]}/util-linux-${UTILLINUX_VERSION}.tar.xz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} "
    NUMJOBS=1
    INSTALL_ARGS="( make install; true )"
    build_with_configure
}

function build_package_aws-sdk-cpp()
{
    if [ ! -e ${CACHE_DIR}/aws-sdk-cpp-${AWSSDKCPP_VERSION}.tar.xz ]; then
	    cd ${BUILD_DIR}
        git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp
        cd aws-sdk-cpp
        git checkout ${AWSSDKCPP_VERSION}
        rm -rf .git
	    cd ..
        mv aws-sdk-cpp aws-sdk-cpp-${AWSSDKCPP_VERSION}
	    tar caf ${CACHE_DIR}/aws-sdk-cpp-${AWSSDKCPP_VERSION}.tar.xz aws-sdk-cpp-${AWSSDKCPP_VERSION}
	    rm -rf aws-sdk-cpp-${AWSSDKCPP_VERSION}
    fi

    (
    export PATH="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/bin:${INSTALL_DIR}/bin:$PATH"
    export LD_LIBRARY_PATH="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib:${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib64:${INSTALL_DIR}/lib:${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"
    export CFLAGS="-I${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/include -I${INSTALL_DIR}/include"
    export CPPFLAGS="-Wno-error -I${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/include -I${INSTALL_DIR}/include"
    export LDFLAGS="-L${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib -L${INSTALL_DIR}/opensSl-${OPENSSL_VERSION}/lib64 -L${INSTALL_DIR}/lib -L${INSTALL_DIR}/lib64"
    export OPENSSL_ROOT_DIR="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}"
    CONFIGURE_ARGS="patch ${BUILD_DIR}/aws-sdk-cpp-${AWSSDKCPP_VERSION}/aws-cpp-sdk-text-to-speech/source/text-to-speech/TextToSpeechManager.cpp ${SCRIPT_DIR}/GNU_Linux/patches/aws-sdk-cpp_amountRead.patch && \
                    cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/include/openssl:${INSTALL_DIR}/openssl\" \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DCMAKE_C_COMPILER=$CC  \
                    -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_CXX_FLAGS=\"-Wno-error -I${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/include/openssl -I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/openssl\" \
                    -DCMAKE_LINK_FLAGS=\"$LDFLAGS\" \
                    -DBUILD_SHARED_LIBS=ON \
                    -DENABLE_TESTING=OFF \
                    ${BUILD_DIR}/aws-sdk-cpp-${AWSSDKCPP_VERSION}"
    VERSION=${AWSSDKCPP_VERSION} \
	   DIRNAME=aws-sdk-cpp-${AWSSDKCPP_VERSION} \
	   TARFILE=aws-sdk-cpp-${AWSSDKCPP_VERSION}.tar.xz \
       build_with_cmake
    )
}

function build_package_robinmap()
{
    git_checkout robinmap ${ROBINMAP_VERSION} "https://github.com/Tessil/robin-map"  "v${ROBINMAP_VERSION}"
    build_with_cmake
}

function build_package_arrayhash()
{
    git_checkout arrayhash "${ARRAYHASH_VERSION}" "https://github.com/Tessil/array-hash" "v${ARRAYHASH_VERSION}"
    build_with_cmake
}

function build_package_sparsemap()
{
    git_checkout sparsemap "${SPARSEMAP_VERSION}" "https://github.com/Tessil/sparse-map" "v${SPARSEMAP_VERSION}"
    build_with_cmake
}

function build_package_hopscotchmap()
{
    git_checkout hopscotchmap "${HOPSCOTCHMAP_VERSION}" "https://github.com/Tessil/hopscotch-map" "v${HOPSCOTCHMAP_VERSION}"
    build_with_cmake
}

function build_package_sparsehash()
{
    git_checkout sparsehash "${SPARSEHASH_VERSION}" "https://github.com/sparsehash/sparsehash" "sparsehash-${SPARSEHASH_VERSION}"
    build_with_configure
}

function build_package_abseil()
{
    git_checkout abseil "${ABSEIL_VERSION}" "https://github.com/abseil/abseil-cpp" "${ABSEIL_VERSION}"
    build_with_cmake
}


function build_package_libbson()
{
    download_tarfile "https://github.com/mongodb/libbson/releases/download/${BSON_VERSION}/libbson-${BSON_VERSION}.tar.gz"
    build_with_cmake
}


function build_package_mongo-c-driver()
{
    download_tarfile "https://github.com/mongodb/mongo-c-driver/releases/download/${MONGOC_VERSION}/mongo-c-driver-${MONGOC_VERSION}.tar.gz"
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INSTALL_PREFIX=\"${INSTALL_DIR}\" \
                    -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
                    -DENABLE_SSL=OPENSSL \
                    -DOPENSSL_ROOT_DIR=${INSTALL_DIR}/openssl-${OPENSSL_VERSION} \
                    -DBSON_ROOT_DIR=\"${INSTALL_DIR}\" \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DCMAKE_C_COMPILER=$CC \
                    -DBUILD_SHARED_LIBS=ON \
                    ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
}
function build_package_mongo-cxx-driver()
{
    #https://mongodb.github.io/mongo-cxx-driver/mongocxx-v3/installation/
    download_tarfile "https://github.com/mongodb/mongo-cxx-driver/archive/r${MONGOCXX_VERSION}.tar.gz" "mongo-cxx-driver-r${MONGOCXX_VERSION}.tar.gz"
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INSTALL_PREFIX=\"${INSTALL_DIR}\" \
                    -DCMAKE_C_FLAGS=\"$CFLAGS -Wall -Wextra -Wno-attributes -Werror -Wno-error=missing-field-initializers $CFLAGS\" \
                    -DCMAKE_CXX_FLAGS=\"$CXXFLAGS -Wall -Wextra -Wno-attributes  -Wno-error=missing-field-initializers $CXXFLAGS\" \
                    -DBOOST_ROOT=\"${BUILD_DIR}/boost_${BOOST_VERSION//./_}\" \
                    -DLIBMONGOC_DIR=\"${INSTALL_DIR}\" \
                    -DBSONCXX_POLY_USE_BOOST=1 \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DBUILD_VERSION=\"${MONGOCXX_VERSION}\" \
                    -DCMAKE_C_COMPILER=$CC \
                    -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
                    -DBUILD_SHARED_LIBS=ON \
                    -DCMAKE_PREFIX_PATH=\"${INSTALL_DIR}\" \
                    -DCMAKE_LIBRARY_PATH=\"${INSTALL_DIR}/lib\" \
                    -DCMAKE_INCLUDE_PATH=\"${INSTALL_DIR}/include\" \
                    ${BUILD_DIR}/${DIRNAME}"
    build_with_cmake
}

function build_package_xerces-c()
{
    download_tarfile "http://ftp.heanet.ie/mirrors/www.apache.org/dist//xerces/c/3/sources/xerces-c-${XERCESCPP_VERSION}.tar.gz"
    build_with_configure
}

function build_package_tec()
{
    # TODO FINISH
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
    CONFIGURE_ARGS="true"
    MAKE_ARGS="make compiler=clang  verbose=1"
    INSTALL_ARGS="rsync -av --exclude='*.d' --exclude='*.o' ${BUILD_DIR}/${DIRNAME}/build/linux*_release/ ${INSTALL_DIR}/lib && \
                  rsync -av --exclude='*.d' --exclude='*.o' ${BUILD_DIR}/${DIRNAME}/build/linux*_debug/ ${INSTALL_DIR}/lib && \
                  mkdir -p ${INSTALL_DIR}/include/tbb && \
                  rsync -av ${BUILD_DIR}/${DIRNAME}/include/tbb/ ${INSTALL_DIR}/include/tbb/ "
    PATH=${INSTALL_DIR}/bin:$PATH \
    CXXFLAGS="-fno-exceptions -I${INSTALL_DIR}/include ${CXXFLAGS}" \
    CFLAGS="-I${INSTALL_DIR}/include ${CFLAGS}" \
        build_with_configure
}

function build_package_tiny-dnn()
{
    #https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz
    download_tarfile "https://github.com/tiny-dnn/tiny-dnn/archive/v${TINYDNN_VERSION}.tar.gz" "tiny-dnn-${TINYDNN_VERSION}.tar.gz"
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DBUILD_SHARED_LIBS=ON \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DUSE_OMP=ON \
                    -DUSE_TBB=ON \
                    -DTBB_INSTALL_DIR=${INSTALL_DIR} \
                    -DUSE_OPENCV=OFF \
                    -DCMAKE_C_COMPILER=$CC \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    ${BUILD_DIR}/${DIRNAME}"
    INSTALL_ARGS="mkdir -p ${INSTALL_DIR}/share/tiny-dnn-${TINYDNN_VERSION}/cmake/Modules && \
                  cp -a ${BUILD_DIR}/${DIRNAME}/{test,data,examples,docs} ${INSTALL_DIR}/share/tiny-dnn-${TINYDNN_VERSION}/ && \
                  rsync -a ${BUILD_DIR}/${DIRNAME}/cmake/Modules/ ${INSTALL_DIR}/share/tiny-dnn-${TINYDNN_VERSION}/cmake/Modules/ && \
                  rsync -a ${BUILD_DIR}/${DIRNAME}/cereal/ ${INSTALL_DIR}/include/cereal/ && \
                  rsync -a ${BUILD_DIR}/${DIRNAME}/third_party/ ${INSTALL_DIR}/include/third_party/  && \
                  rsync -a ${BUILD_DIR}/${DIRNAME}/tiny_dnn/ ${INSTALL_DIR}/include/tiny_dnn/ "
    PATH="$PATH:${INSTALL_DIR}/bin" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${INSTALL_DIR}/lib" \
        build_with_cmake
}

function build_package_qt5()
{
    #http://doc.qt.io/qt-5/linux-building.html
    #http://wiki.qt.io/Building_Qt_5_from_Git
    download_tarfile "http://download.qt.io/official_releases/qt/${QT_VERSION%.*}/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz"
    #export PATH="${INSTALL_DIR}/bin:$PATH"
    #export LD_LIBRARY_PATH="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib:${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib64:${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"
    CONFIGURE_ARGS="( patch -p1 -d ${BUILD_DIR}/qt-everywhere-src-${QT_VERSION} < ${SCRIPT_DIR}/GNU_Linux/patches/qt5-with-clang11.patch ) && \
                    ./configure \
                              -prefix ${INSTALL_DIR}/qt${QT_VERSION} \
                              -opensource -confirm-license -release -shared  \
                              -no-avx -no-avx2 -c++std c++14 \
                              -skip qtsensors -skip qtlocation -skip qtconnectivity -skip qtandroidextras \
                              -skip qtx11extras -skip qtmacextras -skip qtwayland -skip qtquickcontrols \
                              -skip qtquickcontrols2 -skip qtscript -skip qtdoc -skip qtactiveqt \
                              -skip qtwebengine -skip qtwebchannel \
                              -no-opengl  \
                              -nomake examples -nomake tests  \
                              -make libs -openssl-runtime \
                              -I${INSTALL_DIR}/include \
                              -I${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/include \
                              -I${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/include/openssl \
                              -L${INSTALL_DIR}/lib \
                              -platform linux-clang"
    PATH="${INSTALL_DIR}/bin:${PATH}" \
    LD_LIBRARY_PATH="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib:${INSTALL_DIR}/openssl-${OPENSSL_VERSION}/lib64:${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:/usr/lib/x86_64-linux-gnu/:${LD_LIBRARY_PATH}" \
        build_with_configure
}

function build_package_libelf()
{
    download_tarfile "https://fossies.org/linux/misc/old/libelf-${LIBELF_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static "
    build_with_configure
}

function build_package_gmp()
{
    download_tarfile "http://gcc.gnu.org/pub/gcc/infrastructure/gmp-${GMP_VERSION}.tar.bz2"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --with-sysroot=${INSTALL_DIR} --disable-static --enable-cxx "
    build_with_configure
}

function build_package_mpc()
{
    download_tarfile "https://gcc.gnu.org/pub/gcc/infrastructure/mpc-${MPC_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static --with-gmp=${INSTALL_DIR} --with-mpfr=${INSTALL_DIR}"
    build_with_configure
}

function build_package_mpfr()
{
    download_tarfile "https://gcc.gnu.org/pub/gcc/infrastructure/mpfr-${MPFR_VERSION}.tar.bz2"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static --with-gmp=${INSTALL_DIR} "
    build_with_configure
}

function build_package_isl()
{
    download_tarfile "https://gcc.gnu.org/pub/gcc/infrastructure/isl-${ISL_VERSION}.tar.bz2"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} --disable-static --with-gmp-prefix=${INSTALL_DIR} "
    build_with_configure
}


function build_package_gcc()
{
    #"depends": [ "binutils","libelf", "libtool", "mpc", "mpfr", "gmp", "ppl", "cloog", "isl" ],
    download_tarfile "http://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"
    CONFIGURE_ARGS="./configure \
    --prefix=${INSTALL_DIR} \
    --enable-languages=c,c++,fortran \
    --enable-threads=posix \
    --enable-tls \
    --enable-libgomp  \
    --enable-shared \
    --disable-nls \
    --disable-multilib \
    --with-fpmath=sse \
    --program-suffix=-${GCC_VERSION} \
    --enable-__cxa_atexit \
    --with-long-double-128 \
    --enable-secureplt \
    --with-ld=${INSTALL_DIR}/bin/ld \
    --with-as=${INSTALL_DIR}/bin/as \
    --with-gmp=${INSTALL_DIR} \
    --with-mpfr=${INSTALL_DIR} \
    --with-mpc=${INSTALL_DIR} \
    --with-isl=${INSTALL_DIR}"
    MAKE_ARGS="make -j$NUMJOBS configure-build-libiberty && make -j$NUMJOBS all-build-libiberty && make -j$NUMJOBS all-gcc && make -j$NUMJOBS all-target-libgcc && make  -j$NUMJOBS "
    INSTALL_ARGS="make install-gcc && make install-target-libgcc && make install"
    LDFLAGS="-L${INSTALL_DIR}/lib -L${INSTALL_DIR}/lib64" PATH="${INSTALL_DIR}/bin:${PATH}" LD_LIBRARY_PATH="${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64" \
       build_with_configure
}

function build_package_libpng()
{
    download_tarfile "http://prdownloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.xz"
    echo "LDFLAGS = $LDFLAGS"
    echo "CFLAGS = $CFLAGS"
    echo "CXXFLAGS = $CXXFLAGS "
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR}  "
    build_with_configure
}

function build_package_libjpeg-turbo()
{
    # original https://sourceforge.net/projects/libjpeg/files/libjpeg/6b/jpegsrc.v6b.tar.gz
    download_tarfile "https://sourceforge.net/projects/libjpeg-turbo/files/${LIBJPEGTURBO_VERSION}/libjpeg-turbo-${LIBJPEGTURBO_VERSION}.tar.gz"
    build_with_cmake
}

function build_package_libjpeg()
{
    download_tarfile "https://sourceforge.net/projects/libjpeg/files/libjpeg/${LIBJPEG_VERSION}/jpegsrc.v${LIBJPEG_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} "
    build_with_configure
}

function build_package_freetype()
{
    download_tarfile "https://sourceforge.net/projects/freetype/files/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz"
    CONFIGURE_ARGS="./configure --prefix=${INSTALL_DIR} "
    build_with_configure
}

function build_package_jsoncpp()
{
    download_tarfile "https://github.com/open-source-parsers/jsoncpp/archive/${JSONCPP_VERSION}.tar.gz" "jsoncpp-${JSONCPP_VERSION}.tar.gz"
    build_with_cmake
}

function build_package_double-conversion()
{
    download_tarfile "https://github.com/google/double-conversion/archive/v${DOUBLECONVERSION_VERSION}.tar.gz" \
                     "double-conversion-${DOUBLECONVERSION_VERSION}.tar.gz"
    CONFIGURE_ARGS="cmake -G \"$CMAKE_BUILDER\" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DBUILD_SHARED_LIBS=ON \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DCMAKE_C_COMPILER=$CC \
                    ${BUILD_DIR}/${DIRNAME}" \
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
