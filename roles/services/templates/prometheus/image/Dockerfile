FROM prom/prometheus:{{ sonet_general['docker_tag_prometheus']|default("v2.27.1") }}

LABEL project="{{ project }}"

COPY entrypoint.sh /entrypoint.sh
COPY service/prometheus/ /service/prometheus
