#!/bin/sh

function build_package_clang()
{
# not used:
#            -DLIBCXX_LIBCXXABI_WHOLE_ARCHIVE=on -DLIBCXXABI_ENABLE_SHARED=off -DBUILD_SHARED_LIBS=on \
#            -DCMAKE_AR=${INSTALL_DIR}/bin/ar \
#            -DCMAKE_RANLIB=${INSTALL_DIR}/bin/ranlib \
#            -DLLVM_ENABLE_CXX1Y=ON \
#            -DCMAKE_C_LINK_EXECUTABLE=${INSTALL_DIR}/bin/ld.gold \
#            -DCMAKE_CXX_LINK_EXECUTABLE=${INSTALL_DIR}/bin/ld.gold \
#            -DLLVM_ENABLE_LTO=Full \
#            -DLLVM_USE_OPROFILE=ON \
#            -DLLVM_ENABLE_CXX1Y=ON "
# Build with whatever compiler is installed
#            -DCMAKE_CXX_COMPILER=$CXX \
#            -DCMAKE_C_COMPILER=$CC \

if [ ! -e $INSTALL_DIR/clang.done ]; then
    #http://btorpey.github.io/blog/2015/01/02/building-clang/
    CLANG_URL="http://llvm.org"
    CLANG_SVN_URL="http://llvm.org/svn/llvm-project/"
    CLANG_ID="$CLANG_VERSION"
    if [ "$CLANG_USES_SVN" -eq 1 ]; then
        CLANG_ID="$CLANG_SVN_VERSION"
    fi
    CLANG_DIR="clang-${CLANG_ID}"

    if [ ! -f "$INSTALL_DIR/clang.done" ]; then

        cd $BUILD_DIR

        # Download all necessary packages
        PACKAGES="cfe llvm compiler-rt clang-tools-extra libunwind lld lldb openmp polly libcxx libcxxabi"
        for pkg in $PACKAGES; do
            TARFILE="${pkg}-${CLANG_ID}.src.tar.xz"
            UNTARDIR="${pkg}-${CLANG_ID}.src"
            if [ ! -e "$CACHE_DIR/$TARFILE" ]; then
                wget $CLANG_URL/releases/$CLANG_VERSION/$TARFILE -O $CACHE_DIR/$TARFILE
            fi
            rm -rf $UNTARDIR
            tar xaf $CACHE_DIR/$TARFILE
        done

        # move to respective places
        rm -rf ${CLANG_DIR}
        mv -v llvm-${CLANG_ID}.src ${CLANG_DIR}
        mv -v cfe-${CLANG_ID}.src ${CLANG_DIR}/tools/clang
        mv -v clang-tools-extra-${CLANG_ID}.src $CLANG_DIR/tools/clang/tools/extra
        #mv -v libcxx-${CLANG_ID}.src $CLANG_DIR/projects/libcxx
        #mv -v libcxxabi-${CLANG_ID}.src $CLANG_DIR/projects/libcxxabi
        mv -v compiler-rt-${CLANG_ID}.src $CLANG_DIR/projects/compiler-rt

        export PATH="${INSTALL_DIR}/bin:$PATH"
        export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu"
        export CFLAGS="-I$INSTALL_DIR/include -I$INSTALL_DIR/include/ncurses"
        export CPPFLAGS="-I$INSTALL_DIR/include -I$INSTALL_DIR/include/ncurses"
        export CXX_FLAGS="-I$INSTALL_DIR/include -I$INSTALL_DIR/include/ncurses"

        CLANG_OPTS_CCACHE=""
        if [ -n "$USE_CCACHE" ]; then
            CLANG_OPTS_CCACHE="-DLLVM_CCACHE_BUILD=ON \
                               -DLLVM_CCACHE_DIR=$BUILD_DIR/ccache \
                               -DCCACHE_PROGRAM=$(which ccache)"
        fi
        # -DLIBCXX_LIBCXXABI_WHOLE_ARCHIVE=on -DLIBCXXABI_ENABLE_SHARED=off"
        #CLANG_OPTS_COMMON="$CLANG_OPTS_COMMON -DCMAKE_CXX_LINK_FLAGS=\"-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64\" "

        mv -v libunwind-${CLANG_ID}.src $CLANG_DIR/projects/libunwind
        mv -v openmp-${CLANG_ID}.src $CLANG_DIR/projects/openmp
        mv -v lld-${CLANG_ID}.src $CLANG_DIR/tools/lld
        mv -v lldb-${CLANG_ID}.src $CLANG_DIR/tools/lldb
        mv -v polly-${CLANG_ID}.src $CLANG_DIR/tools/polly

        # cmake
        rm -rf clang-build && mkdir -p clang-build
        cd clang-build
        (
            eval "$CLANG_ENV" && \
            cmake -G "$CMAKE_BUILDER"  \
                  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR  \
                  -DCMAKE_EXPORT_COMMANDS=ON \
                  -DLLVM_ENABLE_SPHINX=OFF \
                  -DLLVM_INSTALL_UTILS=ON \
                  -DLLVM_TARGETS_TO_BUILD=X86 \
                  -DLLVM_ENABLE_THREADS=ON \
                  -DLLVM_ENABLE_PIC=ON \
                  -DLLVM_PARALLEL_COMPILE_JOBS=$NUMJOBS \
                  -DLLVM_PARALLEL_LINK_JOBS=$NUMJOBS \
                  -DCMAKE_CXX_LINK_FLAGS=-L$INSTALL_DIR/lib \
                  -DCMAKE_CXX_FLAGS="$CXX_FLAGS" \
                  -DCMAKE_BUILD_TYPE=Release \
                  -DCMAKE_CXX_COMPILER=$CXX \
                  -DCMAKE_C_COMPILER=$CC \
                  -DLLVM_BUILD_TESTS=OFF \
                  -DLLVM_INCLUDE_TESTS=OFF \
                  -DLLVM_BUILD_EXAMPLES=OFF \
                  -DLLVM_INCLUDE_EXAMPLES=OFF \
                  -DCLANG_BUILD_EXAMPLES=OFF \
                  -DBUILD_SHARED_LIBS=ON \
                  -DCMAKE_SHARED_LINKER_FLAGS="-L${INSTALL_DIR}/lib" \
                  -DCLANG_BUILD_TOOLS=ON \
                  -DCMAKE_POLICY_DEFAULT_CMP0056=NEW \
                  -DCMAKE_POLICY_DEFAULT_CMP0058=NEW \
                  $CLANG_OPTS_CCACHE \
                  $BUILD_DIR/$CLANG_DIR && \
            time cmake --build . -- -j$NUMJOBS && \
            cmake --build . --target install && \
            echo $(date +%Y%m%d-%H%M%S) > $INSTALL_DIR/clang.done \
        ) > $BUILD_DIR/clang.log 2> $BUILD_DIR/clang.err || exit 1

        rm -f ${BUILD_DIR}/clang.$STAGE.before ${BUILD_DIR}/clang.after
        rm -rf ${BUILD_DIR}/clang-build
        rm -rf ${BUILD_DIR}/${CLANG_DIR}
        echo $(date +%Y%m%d-%H%M%S) > $INSTALL_DIR/clang.done
    fi
fi
}
