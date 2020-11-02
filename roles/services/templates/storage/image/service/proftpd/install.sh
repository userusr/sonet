#!/bin/bash -e
# this script is run during the image build

addgroup --gid 3000 sftp
useradd --shell /bin/sh --no-create-home --uid 3000 --gid 3000 sftp

cp container/service/proftpd/config/proftpd.conf /etc/proftpd/
cp -r container/service/proftpd/certs /etc/proftpd/

chmod 600 /etc/proftpd/certs/*.key

exit 0
