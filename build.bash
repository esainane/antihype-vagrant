#!/bin/bash
set -ex

#
# Initial setup
#

# Use sudo if we're not root, and always use the "SUDO" environment variable for things that need superuser permissions. This could resolve to a simple wrapper around sup, for example.
SUDO=${SUDO:=}
[ $(id -u) -eq 0 ] || SUDO=${SUDO:=sudo}

"$SUDO" yum groupinstall -y "Development tools";
"$SUDO" yum install -y rpm-build rpmdevtools;
"$SUDO" rpmdev-setuptree;

cd /vagrant/;

which checkinstall 2>/dev/null && false ||
(
  cd checkinstall;
  make;
  "$SUDO" make install;
  # XXX: Hack around prefixing
  "$SUDO" ln -sf /usr/local/lib/installwatch.so /usr/local/lib64/installwatch.so
  which checkinstall;
  "$SUDO" checkinstall -R -y;
)

"$SUDO" yum install -y git;

mkdir -p /vagrant/rpmbuild/RPMS/x86_64/

#
# Build and package libbrine
#

"$SUDO" yum install -y openssl-devel glib2-devel;

cd /vagrant/;

cd libbrine;
make;
# --install=yes as Quassel depends on libbrine to Build
"$SUDO" checkinstall --exclude=/selinux,/sys -R -y --pkgname='libbrine' --install=yes --pkgversion=$(git describe --long --dirty | sed 's/-/_/g') make install PREFIX=/usr;
BRINEPKG=$("$SUDO" ls -t /root/rpmbuild/RPMS/x86_64/ | grep libbrine-.*\.rpm | head -1)
"$SUDO" cp "/root/rpmbuild/RPMS/x86_64/$BRINEPKG" /vagrant/rpmbuild/RPMS/x86_64/;

#
# Build and package Quassel
#

"$SUDO" yum install -y cmake qt-devel qca2-devel;

cd /vagrant/;

cd quassel;
mkdir -p build;
cd build;
cmake -DWANT_CORE=yes -DWANT_QTCLIENT=no -DWANT_MONO=no -DWITH_OXYGEN=no -DWITH_BRINE=yes ..;
make;

"$SUDO" checkinstall -R -y --pkgname='quassel' --install=no --pkgversion=$(git describe --long --dirty | sed 's/-/_/g');
QUASSELPKG=$("$SUDO" ls -t /root/rpmbuild/RPMS/x86_64/ | grep quassel-.*\.rpm | head -1)
"$SUDO" cp "/root/rpmbuild/RPMS/x86_64/$QUASSELPKG" /vagrant/rpmbuild/RPMS/x86_64/;
