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
    CLANG_URL="https://github.com/llvm/llvm-project/"
    CLANG_SVN_URL="http://llvm.org/svn/llvm-project/"

    if [ ! -f "$INSTALL_DIR/clang.done" ]; then

        cd $BUILD_DIR
        rm -rf clang-${CLANG_VERSION}

        # clone the entire clang project (very slow)
        TARFILE="${CACHE_DIR}/clang-${CLANG_VERSION}.tar.xz"
        if [ ! -e "${TARFILE}" ]; then
	    (
	    export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64
            pushd "${CACHE_DIR}"
            if [ ! -d "llvm-project" ]; then
                git clone https://github.com/llvm/llvm-project.git llvm-project
            fi
            cd llvm-project
            git pull
            git checkout llvmorg-${CLANG_VERSION}
            cd ..
	    rsync -a llvm-project/ clang-${CLANG_VERSION}/
            rm -rf clang-${CLANG_VERSION}/.git
            tar caf "${TARFILE}" clang-${CLANG_VERSION}
            rm -rf clang-${CLANG_VERSION}
            popd
	    )
        fi

        # Download all necessary packages
        tar xaf "${TARFILE}"

        # -DLIBCXX_LIBCXXABI_WHOLE_ARCHIVE=on -DLIBCXXABI_ENABLE_SHARED=off"
        #CLANG_OPTS_COMMON="$CLANG_OPTS_COMMON -DCMAKE_CXX_LINK_FLAGS=\"-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64\" "

        # cmake
        rm -rf clang-build && mkdir -p clang-build
        cd clang-build
        (
            export PATH="${INSTALL_DIR}/bin:$PATH"
            export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$INSTALL_DIR/lib64:$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu"
            export LDFLAGS="-L${INSTALL_DIR}/lib -L${INSTALL_DIR}/lib64 -Wl,-rpath,$INSTALL_DIR/lib64 -Wl,-rpath,$INSTALL_DIR/lib"
            export PKG_CONFIG_PATH="$INSTALL_DIR/lib64/pkgconfig:$INSTALL_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
            export CFLAGS="-I$INSTALL_DIR/include -I$INSTALL_DIR/include/ncurses"
            export CPPFLAGS="-I$INSTALL_DIR/include -I$INSTALL_DIR/include/ncurses"
            export CXX_FLAGS="-I$INSTALL_DIR/include -I$INSTALL_DIR/include/ncurses"

            cmake -G "$CMAKE_BUILDER"  \
                  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR  \
                  -DCMAKE_PREFIX_PATH=$INSTALL_DIR \
                  -DCMAKE_BUILD_TYPE=Release \
                  -DCMAKE_CXX_COMPILER=$CXX \
                  -DCMAKE_C_COMPILER=$CC \
                  -DCMAKE_EXPORT_COMMANDS=ON \
                  -DCMAKE_CXX_LINK_FLAGS="-L$INSTALL_DIR/lib -L$INSTALL_DIR/lib64 -Wl,-rpath,$INSTALL_DIR/lib64 -Wl,-rpath,$INSTALL_DIR/lib" \
                  -DCMAKE_CXX_FLAGS="$CXX_FLAGS -I$INSTALL_DIR/include" \
                  -DCMAKE_SHARED_LINKER_FLAGS="-L${INSTALL_DIR}/lib" \
                  -DLLVM_ENABLE_SPHINX=OFF \
                  -DLLVM_ENABLE_DOXYGEN=OFF \
                  -DLLVM_INSTALL_UTILS=ON \
                  -DLLVM_TARGETS_TO_BUILD=X86 \
                  -DLLVM_ENABLE_THREADS=ON \
                  -DLLVM_ENABLE_PIC=ON \
                  -DLLVM_PARALLEL_COMPILE_JOBS=$NUMJOBS \
                  -DLLVM_PARALLEL_LINK_JOBS=$NUMJOBS \
                  -DLLVM_INCLUDE_TESTS=OFF \
                  -DLLVM_BUILD_EXAMPLES=OFF \
                  -DLLVM_BUILD_TESTS=OFF \
                  -DLLVM_BUILD_EXTERNAL_COMPILER_RT=On \
                  -DLLVM_BUILD_TOOLS=ON \
                  -DLLVM_INCLUDE_EXAMPLES=OFF \
                  -DLLVM_INCLUDE_DOCS=OFF \
                  -DLLVM_INCLUDE_EXAMPLES=OFF \
                  -DLLVM_INCLUDE_TOOLS=ON \
                  -DLLVM_INCLUDE_TESTS=OFF \
                  -DLLVM_ENABLE_PROJECTS="clang;compiler-rt;lld;lldb;libunwind;libcxx;libcxxabi;polly;clang-tools-extra" \
                  -DLLVM_BUILD_LLVM_DYLIB:BOOL=ON \
                  -DLLVM_LINK_LLVM_DYLIB:BOOL=ON \
                  -DLLVM_DYLIB_COMPONENTS:STRING=all \
                  -DCLANG_BUILD_EXAMPLES=OFF \
                  -DCLANG_BUILD_TOOLS=ON \
                  -DCLANG_ENABLE_STATIC_ANALIZER=ON \
                  -DCLANG_VENDOR="Vitorian LLC" \
                  -DBUILD_SHARED_LIBS:BOOL=OFF \
                  $CLANG_OPTS_CCACHE \
                  $BUILD_DIR/clang-${CLANG_VERSION}/llvm && \
            cmake --build . -- -j$NUMJOBS && \
            cmake --build . --target install && \
            echo $(date +%Y%m%d-%H%M%S) > $INSTALL_DIR/clang.done \
        ) > $BUILD_DIR/clang.log 2> $BUILD_DIR/clang.err || exit 1

        rm -f ${BUILD_DIR}/clang.$STAGE.before ${BUILD_DIR}/clang.after
        rm -rf ${BUILD_DIR}/clang-build
        rm -rf ${BUILD_DIR}/clang-${CLANG_VERSION}
        echo $(date +%Y%m%d-%H%M%S) > $INSTALL_DIR/clang.done
    fi
fi
}
