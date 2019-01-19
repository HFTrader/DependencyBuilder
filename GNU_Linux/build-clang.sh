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
        PACKAGES="cfe llvm compiler-rt clang-tools-extra libunwind lld lldb openmp polly"
        for pkg in $PACKAGES; do
            TARFILE="${pkg}-${CLANG_ID}.src.tar.xz"
            UNTARDIR="${pkg}-${CLANG_ID}.src"
            if [ ! -e "$CACHE_DIR/$TARFILE" ]; then
                if [ "$pkg" == "cling" ]; then

                    git clone http://root.cern.ch/git/cling.git $UNTARDIR

                    ( git clone http://root.cern.ch/git/llvm.git llvm-${CLANG_ID} && \
                        cd llvm-${CLANG_ID} && \
                            git checkout cling-patches && \
                            cd tools && git clone http://root.cern.ch/git/cling.git cling && \
                                        git clone http://root.cern.ch/git/clang.git clang && \
                            cd clang )

                    tar cJf $CACHE_DIR/$TARFILE $UNTARDIR
                else
                    if [ "$CLANG_USES_SVN" -eq 1 ]; then
                        #http://llvm.org/docs/GettingStarted.html#checkout
                        svn co -q "http://llvm.org/svn/llvm-project/${pkg}/trunk@${CLANG_SVN_VERSION}" "${UNTARDIR}" && \
                            tar --exclude='.svn' cJf "${CACHE_DIR}/${TARFILE}" "${UNTARDIR}" || exit 1
                    else
                        wget $CLANG_URL/releases/$CLANG_VERSION/$TARFILE -O $CACHE_DIR/$TARFILE || exit 1
                    fi
                fi
            fi
            rm -rf $UNTARDIR
            tar xJf $CACHE_DIR/$TARFILE
        done

        # move to respective places
        rm -rf ${CLANG_DIR}
        mv -v llvm-${CLANG_ID}.src ${CLANG_DIR}
        mv -v cfe-${CLANG_ID}.src ${CLANG_DIR}/tools/clang
        mv -v clang-tools-extra-${CLANG_ID}.src $CLANG_DIR/tools/clang/tools/extra
        #mv -v libcxx-${CLANG_ID}.src $CLANG_DIR/projects/libcxx
        #mv -v libcxxabi-${CLANG_ID}.src $CLANG_DIR/projects/libcxxabi
        mv -v compiler-rt-${CLANG_ID}.src $CLANG_DIR/projects/compiler-rt

        CLANG_ENV="export a=1 "
        CLANG_OPTS_COMMON="-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR  \
                           -DLLVM_TARGETS_TO_BUILD=X86 \
                           -DLLVM_ENABLE_PIC=ON \
                           -DLLVM_PARALLEL_COMPILE_JOBS=$NUMJOBS \
                           -DLLVM_PARALLEL_LINK_JOBS=$NUMJOBS \
                           -DCMAKE_CXX_LINK_FLAGS=-L$INSTALL_DIR/lib \
                           -DCMAKE_CXX_FLAGS=-I$INSTALL_DIR/include \
                           -DCMAKE_BUILD_TYPE=Release"
        if [ -n "$USE_CCACHE" ]; then
            CLANG_OPTS_COMMON="$CLANG_OPTS_COMMON \
                           -DLLVM_CCACHE_BUILD=ON \
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

        CLANG_ENV="$CLANG_ENV \
                       PATH=\"${INSTALL_DIR}/bin:$PATH\" \
                       LD_LIBRARY_PATH=\"$INSTALL_DIR/lib:$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu\" \
                       CC=$MYCC \
                       CFLAGS=\"-I$INSTALL_DIR/include\" \
                       CPPFLAGS=\"-I$INSTALL_DIR/include\" \
                       CXX=$MYCXX "
        CLANG_OPTS="$CLANG_OPTS_COMMON \
                        -DCMAKE_CXX_COMPILER=$MYCXX \
                        -DCMAKE_C_COMPILER=$MYCC \
                        -DLLVM_BUILD_TESTS=OFF \
                        -DLLVM_INCLUDE_TESTS=OFF \
                        -DLLVM_BUILD_EXAMPLES=OFF \
                        -DLLVM_INCLUDE_EXAMPLES=OFF \
                        -DCLANG_BUILD_EXAMPLES=OFF \
                        -DCMAKE_SHARED_LINKER_FLAGS=\"-L${INSTALL_DIR}/lib\"
                        -DCLANG_BUILD_TOOLS=ON"

        # cmake
        create_index ${BUILD_DIR}/clang.before
        rm -rf clang-build && mkdir -p clang-build
        cd clang-build
        ( eval "$CLANG_ENV" && \
          cmake -G "$CMAKE_BUILDER" $CLANG_OPTS $BUILD_DIR/$CLANG_DIR && \
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
