#!/bin/bash -e
# this script is run during the image build

SAMBA_BASE=/etc/samba
MASTER_CONFIG=smb.conf.master
SMB_CONFIG=smb.conf
PUBLIC_DIR=/opt/var/storage

if [ ! -d $PUBLIC_DIR ]; then
	mkdir -p $PUBLIC_DIR
{% for share in storage['smb_shares'] %}
	mkdir -p ${PUBLIC_DIR}/{{ share['dir'] }}
{% endfor %}
fi
chown nobody:nogroup $PUBLIC_DIR

cp container/service/samba/config/${MASTER_CONFIG} ${SAMBA_BASE}/${MASTER_CONFIG}
testparm -s ${SAMBA_BASE}/${MASTER_CONFIG} > ${SAMBA_BASE}/${SMB_CONFIG}
