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

directory_copy "/service/grafana/provisioning" "/etc/grafana/provisioning"
file_copy "/service/grafana/conf/grafana.ini" "/etc/grafana/grafana.ini"
file_copy "/service/grafana/conf/ldap.toml" "/etc/grafana/ldap.toml"

exec "$@"
