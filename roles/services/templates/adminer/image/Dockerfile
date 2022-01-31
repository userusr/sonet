# https://hub.docker.com/_/adminer/?tab=tags&page=1&ordering=last_updated
FROM adminer:{{ sonet_general['docker_tag_adminer']|default("4.8.1") }}

LABEL project="{{ project }}"

CMD	[ "php", "-S", "0.0.0.0:8080", "-t", "/var/www/html" ]
