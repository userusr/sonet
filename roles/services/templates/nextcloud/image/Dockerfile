# https://hub.docker.com/_/nextcloud?tab=tags&page=1&ordering=last_updated
FROM nextcloud:{{ sonet_general['docker_tag_nextcloud']|default("21.0.1-apache") }}

LABEL project="{{ project }}"

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        postgresql-client \
    ; \
    rm -rf /var/lib/apt/lists/*

COPY service/nextcloud/config/local.config.php /config/local.config.php
COPY service/nextcloud/apps/ /apps
COPY service/nextcloud/entrypoint.sh /entrypoint.sh
COPY service/nextcloud/wait-for-postgres.sh /wait-for-postgres.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /wait-for-postgres.sh
