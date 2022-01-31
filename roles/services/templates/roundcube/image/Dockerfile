# https://hub.docker.com/r/roundcube/roundcubemail/tags?page=1&ordering=last_updated
FROM roundcube/roundcubemail:{{ sonet_general['docker_tag_roundcubemail']|default("1.4.x-apache") }}

LABEL project="{{ project }}"

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        postgresql-client \
    ; \
    rm -rf /var/lib/apt/lists/*

ADD certs/ca.crt /etc/openssl/certs/ca.crt
ADD config/10-imap-tls.inc.php /var/roundcube/config/10-imap-tls.inc.php
ADD config/20-ldap.inc.php /var/roundcube/config/20-ldap.inc.php

RUN cp /etc/openssl/certs/ca.crt /usr/local/share/ca-certificates \
    && update-ca-certificates

COPY wait-for-postgres.sh /wait-for-postgres.sh
RUN chmod +x /wait-for-postgres.sh
