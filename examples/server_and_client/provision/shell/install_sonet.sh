#!/usr/bin/env bash
set -Eeuo pipefail

export DOCKER_CLIENT_TIMEOUT=240
export COMPOSE_HTTP_TIMEOUT=240

bind_ip=127.0.0.1
rev_ip=0.0.127
up_services=''

if [ "$#" -ge 1 ]; then
    bind_ip=$1
    rev_ip=$(echo "${bind_ip}" | awk -F "." '{print $3"."$2"."$1}')
    shift
    up_services="$@"
fi

sudo apt-get install -y python3-venv

if [ ! -d sonet.local ]; then
    git clone https://github.com/userusr/sonet.local.git
fi

cd sonet.local
git submodule init
git submodule update

make venv
source ./venv/bin/activate

sed -i "s/docker_bind_ip: 127.0.0.1/docker_bind_ip: ${bind_ip}/" configs/sonet_local/playbook.yml

cat <<EOF>configs/sonet_local/vars/99-override.yml
---
sonet_dns:
  root_forward: [ '8.8.8.8' ]
  zones:
    - zonefile: "{{ sonet_general['domain'] }}.zone"
      name: "{{ sonet_general['domain'] }}"
      domain_name: "@"
      name_server_fqdn: "ns.{{ sonet_general['domain'] }}."
      admin_email: "root@ns.{{ sonet_general['domain'] }}."
      members:
        - { hostname: '@', type: 'NS', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: '', type: 'MX', address: "10 mail.{{ sonet_general['domain'] }}." }
        - { hostname: "ns.{{ sonet_general['domain'] }}.", type: 'A', address: "${bind_ip}" }
        - { hostname: "{{ sonet_general['ldap_hostname'] }}.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "mail.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "gitlab.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "mattermost.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "redmine.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "ldapadmin.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "storage.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "pki.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "excalidraw.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "nextcloud.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "onlyoffice.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "drawio.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "portainer.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "grafana.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "registry.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "adminer.{{ sonet_general['domain'] }}.", type: 'CNAME', address: "ns.{{ sonet_general['domain'] }}." }
    - zonefile: "${rev_ip}.in-addr.arpa.zone"
      name: "${rev_ip}.in-addr.arpa.zone"
      domain_name: "@"
      name_server_fqdn: "ns.{{ sonet_general['domain'] }}."
      admin_email: "root@ns.{{ sonet_general['domain'] }}."
      members:
        - { hostname: '@', type: 'NS', address: "ns.{{ sonet_general['domain'] }}." }
        - { hostname: "ns.{{ sonet_general['domain'] }}.", type: 'PTR', address: "${bind_ip}" }
EOF

make init
make build

./build/sonet_local/source/sonet up ${up_services}
