#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

mkdir -p /container/service/opendkim/assets/keys

touch /container/service/opendkim/assets/config/KeyTable
touch /container/service/opendkim/assets/config/SigningTable

ln -sf /container/service/opendkim/assets/config/opendkim.conf /etc/opendkim.conf
ln -sf /container/service/opendkim/assets/config/TrustedHosts /etc/opendkim/TrustedHosts
ln -sf /container/service/opendkim/assets/config/KeyTable /etc/opendkim/KeyTable
ln -sf /container/service/opendkim/assets/config/SigningTable /etc/opendkim/SigningTable

chmod 755 /container/service/opendkim/assets/keys
chmod 600 /container/service/opendkim/assets/keys/*
chown opendkim:opendkim -R /container/service/opendkim/assets/keys
chown opendkim:opendkim -R /etc/opendkim
chown opendkim:opendkim -R /etc/opendkim.conf

exit 0
