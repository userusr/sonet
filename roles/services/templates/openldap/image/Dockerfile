# https://hub.docker.com/r/osixia/openldap/tags?page=1&ordering=last_updated
FROM osixia/openldap:{{ conf['docker_tag_openldap']|default("1.4.0") }}

LABEL project="{{ project }}"

ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD certs /container/service/slapd/assets/certs
