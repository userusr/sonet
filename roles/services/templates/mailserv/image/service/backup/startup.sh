#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# install image tools
ln -sf /container/service/backup/assets/tool/* /sbin/

# add cron jobs
ln -sf /container/service/backup/assets/cronjobs /etc/cron.d/backup
chmod 600 /container/service/backup/assets/cronjobs

exit 0
