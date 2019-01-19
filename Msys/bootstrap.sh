
MYARCH=${MYARCH:-"native"}
MYCC=${MYCC:-"${INSTALL_DIR}/bin/clang"}
MYCXX=${MYCXX:-"${INSTALL_DIR}/bin/clang++"}
MYFC=${MYFC:-"$(which gfortran)"}
if [ -z "$MYFC" ]; then
    echo "Fortran compiler not found"
    exit 1
fi

NASM_PATH="D:\Program Files (x86)\NASM"
MSPATH="C:\Program Files (x86)\MSBuild\14.0\bin"
ACTIVE_PERL_PATH="D:\Perl64"
set -e

GCC_PATH=$(which gcc)
SYSROOT=
#CFLAGS="-m64 -march=$MYARCH -mtune=$MYARCH"
#CXXFLAGS="-m64 -march=$MYARCH -mtune=$MYARCH"
#CPPFLAGS="-m64 -march=$MYARCH -mtune=$MYARCH -I/usr/include "

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


# Check if we have all the necessary tools
pacman -S --needed bash bash-completion bsdcpio bsdtar bzip2 ca-certificates catgets coreutils crypt curl dash db expat \
  file filesystem findutils flex gawk gcc-libs gdbm gettext git gmp gnupg grep gzip heimdal heimdal-libs icu inetutils  \
  info less libarchive libasprintf libassuan libbz2 libcatgets libcrypt libcurl libdb libedit libexpat libffi libgdbm   \
  libgettextpo libgpg-error libgpgme libiconv libidn libintl liblzma liblzo2 libmetalink libnettle libopenssl libp11-kit \
  libpcre libpcre16 libpcre32 libpcrecpp libpcreposix libreadline libsqlite libssh2 libtasn1 libutil-linux libxml2 lndir \
  m4 make mingw-w64-x86_64-binutils mingw-w64-x86_64-bzip2 mingw-w64-x86_64-ca-certificates mingw-w64-x86_64-c-ares      \
  mingw-w64-x86_64-cmake mingw-w64-x86_64-crt-git mingw-w64-x86_64-curl mingw-w64-x86_64-expat mingw-w64-x86_64-gcc \
  mingw-w64-x86_64-gcc-ada mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs \
  mingw-w64-x86_64-gcc-objc mingw-w64-x86_64-gdb mingw-w64-x86_64-gdbm mingw-w64-x86_64-gettext mingw-w64-x86_64-gmp \
  mingw-w64-x86_64-gnutls mingw-w64-x86_64-headers-git mingw-w64-x86_64-isl mingw-w64-x86_64-jansson \
  mingw-w64-x86_64-jsoncpp mingw-w64-x86_64-libarchive mingw-w64-x86_64-libffi mingw-w64-x86_64-libiconv \
  mingw-w64-x86_64-libidn mingw-w64-x86_64-libmangle-git mingw-w64-x86_64-libmetalink mingw-w64-x86_64-libssh2 \
  mingw-w64-x86_64-libsystre mingw-w64-x86_64-libtasn1 mingw-w64-x86_64-libtre-git mingw-w64-x86_64-libuv \
  mingw-w64-x86_64-libwinpthread-git mingw-w64-x86_64-lz4 mingw-w64-x86_64-lzo2 mingw-w64-x86_64-make mingw-w64-x86_64-mpc \
  mingw-w64-x86_64-mpfr mingw-w64-x86_64-ncurses mingw-w64-x86_64-nettle mingw-w64-x86_64-nghttp2 mingw-w64-x86_64-openssl \
  mingw-w64-x86_64-p11-kit mingw-w64-x86_64-pkg-config mingw-w64-x86_64-python2 mingw-w64-x86_64-readline \
  mingw-w64-x86_64-rtmpdump-git mingw-w64-x86_64-spdylay mingw-w64-x86_64-tcl mingw-w64-x86_64-termcap mingw-w64-x86_64-tk \
  mingw-w64-x86_64-tools-git mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads-git mingw-w64-x86_64-xz \
  mingw-w64-x86_64-zlib mintty mpfr msys2-keyring msys2-launcher-git msys2-runtime ncurses openssh openssl p11-kit pacman \
  pacman-mirrors pactoys-git pax-git pcre perl perl-Authen-SASL perl-Convert-BinHex perl-Encode-Locale perl-Error \
  perl-File-Listing perl-HTML-Parser perl-HTML-Tagset perl-HTTP-Cookies perl-HTTP-Daemon perl-HTTP-Date perl-HTTP-Message \
  perl-HTTP-Negotiate perl-IO-Socket-SSL perl-IO-stringy perl-libwww perl-LWP-MediaTypes perl-MailTools perl-MIME-tools \
  perl-Net-HTTP perl-Net-SMTP-SSL perl-Net-SSLeay perl-TermReadKey perl-TimeDate perl-URI perl-WWW-RobotRules pkgfile \
  rebase rsync sed tar tftp-hpa time ttyrec tzcode util-linux vim wget which xz zlib \
  2>/dev/null || exit 1

haserr=0
if [ -z "${VS140COMNTOOLS}" ]; then
    echo "Visual Studio 2015 is not installed"
    haserr=1
fi

if [ -z "$COMSPEC" ]; then
    echo "Please set COMSPEC to your CMD.EXE executable"
    haserr=1
fi

if [ ! "$MSYSTEM" == "MINGW64" ]; then
    echo "You do not have MSYS2 installed. Please download it from https://msys2.github.io/"
    haserr=1
fi

if [ ! -e "$ACTIVE_PERL_PATH/bin/perl" ]; then
    echo "You do not seem to have Active Perl installed on $ACTIVE_PERL_PATH"
    echo "Please download it from http://www.activestate.com/activeperl/downloads and install it"
    echo "Also update the ACTIVE_PERL_PATH on top of this script to point to the directory you installed it"
    haserr=1
fi

if [ haserr == 1 ]; then
    echo "Errors detected. Bailing out."
    exit 1
fi

# MS VISUAL STUDIO PATH
$COMSPEC <<AHERE
@echo off
call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" x86_amd64
echo %PATH% > Win64Path.log
set > Environment.log
AHERE

WINPATH=$(cat Win64Path.log)
PATH=$PATH:$(cygpath  "$ACTIVE_PERL_PATH" )
PATH=$PATH:$(cygpath  "$NASM_PATH" ) 
PATH=$PATH:$(cygpath  "$MSPATH" ) 
PATH=$PATH:$(cygpath -p "$WINPATH" ) 

# we need to escape this entire mess
export PATH=$(echo $PATH | sed 's/\([ ()]\)/\\\1/g' ) 

  