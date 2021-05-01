# https://hub.docker.com/r/roundcube/roundcubemail/tags?page=1&ordering=last_updated
FROM roundcube/roundcubemail:{{ conf['docker_tag_roundcubemail']|default("1.4.x-apache") }}

LABEL project="{{ project }}"

ADD certs/ca.crt /etc/openssl/certs/ca.crt
ADD config/10-imap-tls.inc.php /var/roundcube/config/10-imap-tls.inc.php

RUN cp /etc/openssl/certs/ca.crt /usr/local/share/ca-certificates \
    && update-ca-certificates

COPY docker-entrypoint.sh /
