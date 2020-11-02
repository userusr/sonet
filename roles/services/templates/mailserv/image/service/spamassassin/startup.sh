#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

ln -sf /container/service/spamassassin/assets/config/* /etc/spamassassin/
ln -sf /container/service/spamassassin/assets/cronjobs /etc/cron.d/spamassassin
chmod 600 /container/service/spamassassin/assets/cronjobs

exit 0
