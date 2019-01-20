# defaults to clang - if not, use gcc
CC=$(which clang)
CXX=$(which clang++)
CC=${CC:-gcc}
CXX=${CXX:-g++}
echo "Compilers: $CC $CXX"

# install swig, libedit
# This is only necessary so we get the latest and greatest to build the rest
build_package coreutils
build_package m4
build_package bison
build_package flex
build_package libpcap
build_package libtool
build_package binutils
build_package autoconf
build_package automake
build_package ninja
build_package cmake
build_package ncurses
#build_package gtest
build_package libelf
build_package gmp
build_package mpfr
build_package mpc
build_package gcc
build_package python
build_package pcre
build_package swig
build_package libedit
build_package clang

# this guy cannot be compiled with clang
build_package openonload

# Now we set the flags and ready to cross compile
export CC="${INSTALL_DIR}/bin/clang" #${MYCC}"
export CXX="${INSTALL_DIR}/bin/clang++" #"${MYCXX}"
export PATH="${INSTALL_DIR}/bin:$PATH"
#export LD_LIBRARY_PATH="${INSTALL_DIR}/lib:$LD_LIBRARY_PATH"
export LDFLAGS="-L${INSTALL_DIR}/lib"
export CFLAGS="-O3 -march=$MYARCH -mtune=$MYARCH"
export CXXFLAGS="-O3 -m64 -march=$MYARCH -mtune=$MYARCH"
export FFLAGS="-O3 -march=$MYARCH -fPIC"


build_package openonload
build_package zlib
build_package libzip
build_package bzip2
build_package libxz
build_package tar
build_package openssl
build_package libcurl
#build_package sasl
build_package boost
CMAKE_BUILDER="'Unix Makefiles'" build_package lapack  # Some Ninja/Fortran incompatibility :(
build_package openblas
build_package arpack
build_package armadillo
build_package yaml-cpp
build_package cryptopp
build_package util-linux
build_package libbson
build_package mongo-c-driver
build_package mongo-cxx-driver
build_package yasm
build_package nasm
build_package tbb
build_package tiny-dnn
build_package libjpeg-turbo
build_package libpng
build_package freetype
build_package qt5
build_package jsoncpp
build_package double-conversion
build_package aws-sdk-cpp
#build_package libx11
#build_package libxrender
#build_package libxfixes
#build_package libxcb
#build_package libxi
#build_package libxext

#build_package xerces-c
#build_package wxwidgets
#build_package tcl
