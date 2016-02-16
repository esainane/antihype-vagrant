#!/bin/bash
set -ex

SUDO=${SUDO:=}
[ $(id -u) -eq 0 ] || SUDO=${SUDO:=sudo}

LATEST_BRINE=$(ls -t /vagrant/rpmbuild/RPMS/x86_64/libbrine-*.rpm | head -1)
LATEST_QUASSEL=$(ls -t /vagrant/rpmbuild/RPMS/x86_64/quassel-*.rpm | head -1)

"$SUDO" yum install -y "$LATEST_BRINE" ||:;
"$SUDO" yum install -y "$LATEST_QUASSEL" ||:;

mkdir -p /etc/quassel/ /var/lib/quassel;
# TODO: don't recreate cert if exists/not expired?
# openssl verify /tmp/test.pem | grep -Eo 'error [[:alnum:]]+' | grep -Ev 'error 18\b'
[ -f /opt/quassel/var/quasselCert.pem -a -f /opt/quassel/var/quasselCert.pem ] || openssl req -x509 -nodes -days 365 -newkey rsa:4096 -subj "/C=NZ/ST=vagranttest/L=localvagranttest/O=localvagrant/CN=localhost" -keyout /opt/quassel/var/quasselCert.pem -out /opt/quassel/var/quasselCert.pem;

grep -q quassel /etc/passwd || "$SUDO" adduser --system --user-group --no-create-home --shell /sbin/nologin --password x quassel;
"$SUDO" chown -R quassel:quassel /etc/quassel;

"$SUDO" yum install -y postgresql-server;
ls /var/lib/pgsql/data/* > /dev/null 2>&1 || "$SUDO" postgresql-setup initdb;
"$SUDO" service postgresql start ||:;
"$SUDO" su postgres -c "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='quassel'\"" | grep -q 1 || su postgres -c "psql -c \"create user quassel password 'localvagrant'\"";
"$SUDO" su postgres -c "psql postgres -tAc \"SELECT 1 FROM pg_database WHERE datname = 'quassel'\"" | grep -q 1 || su postgres -c "createdb -U postgres -O quassel -E UTF8 quassel;"
"$SUDO" su postgres -c psql <<EOF
\timing on
SET maintenance_work_mem = '512MB';
VACUUM ANALYZE;
CLUSTER backlog USING backlog_bufferid_idx;
VACUUM ANALYZE;
ALTER ROLE quassel SET random_page_cost TO DEFAULT;
ALTER ROLE quassel SET work_mem TO '16MB';
\drds
EOF
[ -f /usr/lib64/systemd/system/quasselcore.service ] || cat > /usr/lib/systemd/system/quasselcore.service <<EOF
[Unit]
Description=Quassel Core
After=network.target

[Service]
User=quassel
Group=quassel
ExecStart=/opt/bin/quasselcore --require-ssl --configdir=/var/lib/quassel --select-backend=PostgreSQL

[Install]
WantedBy=multi-user.target
EOF
