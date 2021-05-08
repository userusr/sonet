#!/bin/sh
set -eu

# return true if specified directory is empty
directory_empty() {
    [ -z "$(ls -A "$1/")" ]
}

if [ ! -d "/etc/coredns/zones" ] || directory_empty "/etc/coredns/zones"; then
    cp -r /service/coredns/zones /etc/coredns/
fi

if [ ! -f "/etc/coredns/Corefile" ]; then
    cp /service/coredns/Corefile /etc/coredns/Corefile
fi

exec "$@"
