#!/bin/bash -e

chown -R 3000:3000 /opt/var/storage

exec proftpd --nodaemon
