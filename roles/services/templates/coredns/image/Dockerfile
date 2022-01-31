# https://hub.docker.com/_/golang?tab=tags&page=1&ordering=last_updated
FROM golang:{{ sonet_general['docker_tag_coredns_golang']|default("1.16.4-buster") }}

LABEL project="{{ project }}"

RUN git clone --depth 1 --branch {{ sonet_general['git_tag_coredns']|default("v1.8.3") }} https://github.com/coredns/coredns.git /coredns
RUN cd /coredns && make

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY Corefile /service/coredns/Corefile
COPY zones /service/coredns/zones

ENTRYPOINT ["/entrypoint.sh"]
