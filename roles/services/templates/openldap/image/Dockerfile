# https://hub.docker.com/r/osixia/openldap/tags?page=1&ordering=last_updated
FROM osixia/openldap:{{ conf['docker_tag_openldap']|default("stable-amd64") }}

LABEL project="{{ project }}"

ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD certs /container/service/slapd/assets/certs
