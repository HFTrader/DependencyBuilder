#!/bin/sh

########################################################################
# build boost - mongocxx needs 1.61 (won't work with 1.62+ because of
# removal of string_ref)
########################################################################
build_package_boost()
{
cd $BUILD_DIR
if [ ! -f "$INSTALL_DIR/boost.done" ]; then

    #    git clone --recursive https://github.com/boostorg/boost.git boost
    #    git checkout boost-1.61.0
    #    git submodule update
    #    git clone --recursive https://github.com/boostorg/boost.git boost
    #    git checkout boost-1.61.0
    #    git submodule update
    BOOST_TAR_FILE="boost_${BOOST_VERSION//./_}.tar.gz"
    BOOST_DIR="boost_${BOOST_VERSION//./_}"

    # make sure the directory is empty
    rm -rf BOOST_DIR

    # Download if file not there yet
    if [ ! -e $CACHE_DIR/$BOOST_TAR_FILE ]; then
        wget --no-check-certificate https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/${BOOST_TAR_FILE} -O $CACHE_DIR/$BOOST_TAR_FILE || exit 1
    fi
    tar xaf $CACHE_DIR/$BOOST_TAR_FILE
    cd $BOOST_DIR

    cat <<EOF > tools/build/src/user-config.jam
using python : $PYTHON_VERSION : ${INSTALL_DIR}/bin/python3 : <compileflags>-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/python${PYTHON_VERSION};
#using clang-custom  : $CLANG_VERSION : : <compileflags>-I${INSTALL_DIR}/include <linkflags>-L${INSTALL_DIR}/lib -L${INSTALL_DIR}/lib64;
EOF

    # make build binary
    if [ ! -f b2 ]; then
        #./bootstrap.sh
        CXXFLAGS="$CXXFLAGS -I${INSTALL_DIR}/include" \
        CFLAGS="$CFLAGS -I${INSTALL_DIR}/include" \
        PATH=$PATH:${INSTALL_DIR}/bin \
        LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$LD_LIBRARY_PATH \
        ./bootstrap.sh -includedir=${INSTALL_DIR}/include \
             -libdir=${INSTALL_DIR}/lib --with-toolset=clang \
             --with-python=${INSTALL_DIR}/bin/python3 \
             --with-python-root=${INSTALL_DIR} || exit 1
    fi

    ( CXXFLAGS="$CXXFLAGS -I${INSTALL_DIR}/include" CFLAGS="$CFLAGS -I${INSTALL_DIR}/include" \
      PATH=${INSTALL_DIR}/bin:$PATH LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$LD_LIBRARY_PATH \
      ./b2 -q -a -j$NUMJOBS --layout=tagged --build-type=minimal --prefix="${INSTALL_DIR}"  \
      variant=release link=shared threading=multi toolset=clang address-model=64 \
      linkflags="$CXXFLAGS" cxxflags="$CXXFLAGS -I$INSTALL_DIR/include" install \
      && echo $(date +%Y%m%d-%H%M%S) > $INSTALL_DIR/boost.done \
    ) > $BUILD_DIR/boost.log 2> $BUILD_DIR/boost.err \
        || exit 1

    rm -f ${BUILD_DIR}/boost.before ${BUILD_DIR}/boost.after
    rm -rf ${BUILD_DIR}/$BOOST_DIR
fi
}
