#!/bin/bash
set -ex

yum install -y cmake qt-devel qca2-devel git

cd /vagrant/

cd quassel
mkdir -p build
cd build
cmake -DWANT_CORE=yes -DWANT_QTCLIENT=no -DWANT_MONO=no -DWITH_OXYGEN=no -DCMAKE_INSTALL_PREFIX:PATH=/opt/quassel ..
make
checkinstall -R -y --pkgname='quassel' --pkgversion=$(git describe --long --dirty | sed 's/-/_/g')


mkdir -p /opt/quassel/var
# TODO: don't recreate cert if exists/not expired?
# openssl verify /tmp/test.pem | grep -Eo 'error [[:alnum:]]+' | grep -Ev 'error 18\b'
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /opt/quassel/var/quasselCert.pem -out /opt/quassel/var/quasselCert.pem

adduser --system --user-group --no-create-home --shell /sbin/nologin --password x quassel
chown -R quassel:quassel /opt/quassel

yum install -y postgresql-server
createuser -A -D -P -E -U postgres -W quassel
createdb -U postgres -O quassel -E UTF8 quassel
