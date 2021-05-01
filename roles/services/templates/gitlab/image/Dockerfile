# https://hub.docker.com/r/gitlab/gitlab-ce/tags?page=1&ordering=last_updated
FROM gitlab/gitlab-ce:{{ conf['docker_tag_gitlab']|default("13.11.3-ce.0") }}

LABEL project="{{ project }}"

COPY certs /certs
RUN cat /certs/ca.crt >> /opt/gitlab/embedded/ssl/cert.pem
