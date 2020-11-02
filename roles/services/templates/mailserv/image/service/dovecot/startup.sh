#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# dovecot
ln -sf /container/service/dovecot/assets/config/dovecot.conf /etc/dovecot/dovecot.conf
ln -sf /container/service/dovecot/assets/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext
ln -sf /container/service/dovecot/assets/config/dovecot-trash.conf.ext /etc/dovecot/dovecot-trash.conf.ext
ln -sf /container/service/dovecot/assets/config/conf.d/* /etc/dovecot/conf.d

[ -f /etc/dovecot/dovecot-ldap-userdb.conf.ext ] && rm -f /etc/dovecot/dovecot-ldap-userdb.conf.ext
ln -sf /container/service/dovecot/assets/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap-userdb.conf.ext

exit 0
