#!/bin/bash

find ./ -name 7z* | xargs rm -rf
find ./ -name *doc | xargs rm -rf
find ./ -name *man | xargs rm -rf

rm -rf \
    build \
    dev-utils \
    home \
    logs \
    craft \
    sbom \
    phrasebooks \
    var \
    usr \
    translations \
    libexec/*.debug \
    lib/clang \
    lib/cmake/clang \
    lib/cmake/lld \
    lib/cmake/llvm \
    lib/cmake/Qt6/config.tests \
    lib/gettext \
    lib/libclang* \
    lib/libLLVM* \
    lib/objects-RelWithDebInfo \
    lib/perl5 \
    lib/python3.11 \
    lib/python \
    share/ECM/test-modules \
    share/info \
    share/texinfo \
    share/locale \
    share/xml \
    share/clang \
    share/clang-doc \
    share/scan-build \
    share/scan-view \
    share/opt-viewer \
    plugins/qmlls \
    plugins/qmllint

find ./bin \( -type f -o -type l \) \
    ! -name "androiddeployqt" \
    ! -name "androidtestrunner" \
    ! -name "lconvert" \
    ! -name "lrelease" \
    ! -name "lupdate" \
    ! -name "qdbuscpp2xml" \
    ! -name "qdbusxml2cpp" \
    ! -name "qmake" \
    ! -name "qmldom" \
    ! -name "qmlformat" \
    ! -name "qmllint" \
    ! -name "qmlplugindump" \
    ! -name "qmlprofiler" \
    ! -name "qmltc" \
    ! -name "qmltestrunner" \
    ! -name "qmltime" \
    ! -name "qtpaths" \
    ! -name "svgtoqml" \
    -delete