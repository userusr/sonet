#!/bin/sh
set -eu

# return true if specified directory is empty
directory_empty() {
    [ -z "$(ls -A "$1/")" ]
}

directory_copy() {
    if [ ! -d "$2" ] || directory_empty "$2"; then
        cp -r $1 $2
    fi
}

file_copy() {
    if [ ! -f "$2" ]; then
        cp $1 $2
    fi
}

directory_copy "/service/private" "/etc/pki/tls/private"
directory_copy "/service/certs" "/etc/pki/tls/certs"
directory_copy "/service/pki" "/opt/caddy/pki"
file_copy "/service/Caddyfile" "/etc/caddy/Caddyfile"

exec "$@"
