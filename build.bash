#!/bin/bash
set -ex

#
# Initial setup
#

yum groupinstall -y "Development tools";
yum install -y rpm-build rpmdevtools;
rpmdev-setuptree;

cd /vagrant/;

which checkinstall 2>/dev/null ||
(
  cd checkinstall;
  make;
  su;
  make install;
  # XXX: Hack around prefixing
  ln -s /usr/local/lib/installwatch.so /usr/local/lib64/installwatch.so
  checkinstall -R -y;
)

yum install -y git;

mkdir -p /vagrant/rpmbuild/RPMS/x86_64/

#
# Build and package libbrine
#

yum install -y openssl-devel glib2-devel;

cd /vagrant/;

cd libbrine;
make;
checkinstall -R -y --pkgname='libbrine' --pkgversion=$(git describe --long --dirty | sed 's/-/_/g') make install PREFIX=/usr;
cp /root/rpmbuild/RPMS/x86_64/libbrine-*.rpm /vagrant/rpmbuild/RPMS/x86_64/;


#
# Build and package Quassel
#

yum install -y cmake qt-devel qca2-devel;

cd /vagrant/;

cd quassel;
mkdir -p build;
cd build;
cmake -DWANT_CORE=yes -DWANT_QTCLIENT=no -DWANT_MONO=no -DWITH_OXYGEN=no ..;
make;
# FIXME: Don't build package as root
checkinstall -R -y --pkgname='quassel' --pkgversion=$(git describe --long --dirty | sed 's/-/_/g');
cp /root/rpmbuild/RPMS/x86_64/quassel-*.rpm /vagrant/rpmbuild/RPMS/x86_64/;
