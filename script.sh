#!/usr/bin/env bash

MASON_NAME=geowave-jace
MASON_VERSION=0.9.1
MASON_LIB_FILE=lib/libgeowave.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download http://s3.amazonaws.com/geowave-rpms/dev/TARBALL/geowave-0.9.1-SNAPSHOT-ad17ef5-jace.tar.gz \
    0076e2aa22e32b5ab8513835abff574031bab0ce

    mason_extract_tar_gz
    
    export MASON_BUILD_PATH=${MASON_ROOT}/.build
}

function dep() {
    ${MASON_DIR:-~/.mason}/mason install $1 $2
    ${MASON_DIR:-~/.mason}/mason link $1 $2
}

function all_deps() {
    dep cmake 3.2.2 &
    dep boost 1.57.0 &
    dep boost_libsystem 1.57.0 &
    dep boost_libthread 1.57.0 &
    wait
}

function mason_prepare_compile {
    cd $(dirname ${MASON_ROOT})
    all_deps
    MASON_HOME=${MASON_ROOT}/.link
    PATH=${MASON_HOME}/bin:$PATH
}

function mason_compile {
    cd geowave-jace
    mkdir -p build
    cd build
    cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
      -DBOOST_INCLUDEDIR=${MASON_HOME}/include \
      -DBOOST_LIBRARYDIR=${MASON_HOME}/lib \
      -DCMAKE_BUILD_TYPE=Release
    make -j${MASON_CONCURRENCY}
    make install
    mkdir -p ${MASON_PREFIX}/bin
    mv ../bin/*.jar ${MASON_PREFIX}/bin
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lgeowave"
}

function mason_clean {
    make clean
}

mason_run "$@"
