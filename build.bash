#!/bin/bash
set -ex

yum groupinstall -y "Development tools"
yum install -y rpm-build rpmdevtools
rpmdev-setuptree

cd /vagrant/

which checkinstall 2>/dev/null ||
(
  cd checkinstall
  make
  su
  make install
  checkinstall -R -y
)
