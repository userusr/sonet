#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

chown -R clamav:clamav /var/run/clamav

ln -sf /container/service/clamav/assets/cronjobs /etc/cron.d/clamav
chmod 600 /container/service/clamav/assets/cronjobs

exec /usr/sbin/clamd
