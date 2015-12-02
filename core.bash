#!/bin/bash
set -ex

yum install -y cmake qt-devel qca2-devel git

cd /vagrant/

cd quassel
mkdir -p build
cd build
cmake -DWANT_CORE=yes -DWANT_QTCLIENT=no -DWANT_MONO=no ..
make
checkinstall -R -y --pkgname='quassel' --pkgversion=$(git describe --long --dirty | sed 's/-/_/g')
