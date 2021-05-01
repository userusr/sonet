# https://hub.docker.com/r/coredns/coredns/tags?page=1&ordering=last_updated
FROM coredns/coredns:{{ conf['docker_tag_coredns']|default("1.8.3") }}

LABEL project="{{ project }}"

COPY Corefile /etc/coredns/Corefile
COPY zones /etc/coredns/zones/

CMD ["-conf", "/etc/coredns/Corefile"]
