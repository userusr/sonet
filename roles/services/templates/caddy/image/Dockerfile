# https://hub.docker.com/_/caddy?tab=tags&page=1&ordering=last_updated
FROM caddy:{{ sonet_general['docker_tag_caddy']|default("2.3.0") }}

LABEL project="{{ project }}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY Caddyfile /service/Caddyfile

ADD private /service/private/
ADD certs /service/certs/
ADD pki /service/pki/

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
