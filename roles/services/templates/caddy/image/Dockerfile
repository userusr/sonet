FROM caddy:2.1.1

LABEL project="{{ project }}"

COPY Caddyfile /etc/caddy/Caddyfile

ADD private /etc/pki/tls/private/
ADD certs /etc/pki/tls/certs/
ADD pki /opt/caddy/pki/

EXPOSE 80 443
