# https://hub.docker.com/_/caddy?tab=tags&page=1&ordering=last_updated
FROM caddy:{{ conf['docker_tag_caddy']|default("2.3.0") }}

LABEL project="{{ project }}"

COPY Caddyfile /etc/caddy/Caddyfile

ADD private /etc/pki/tls/private/
ADD certs /etc/pki/tls/certs/
ADD pki /opt/caddy/pki/

EXPOSE 80 443
