#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# postfix
ln -sf /container/service/postfix/assets/config/* /etc/postfix/

# prevent fatal: unknown service: smtp/tcp
# http://serverfault.com/questions/655116/postfix-fails-to-send-mail-with-fatal-unknown-service-smtp-tcp
cp -f /etc/services /var/spool/postfix/etc/services

# copy dns settings to chroot jail
cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

# fix files permissions
chown -R vmail:vmail /var/mail
chmod 644 /etc/postfix/*.cf
chmod 644 /container/service/postfix/assets/config/*.cf

touch /var/log/mail.log
ln -sf /proc/1/fd/1 /var/log/mail.log

exit 0
