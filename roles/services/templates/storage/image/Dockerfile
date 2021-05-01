# Use osixia/light-baseimage
# https://github.com/osixia/docker-light-baseimage
# https://hub.docker.com/r/osixia/light-baseimage/tags?page=1&ordering=last_updated
FROM osixia/light-baseimage:{{ conf['docker_tag_storage_baseimage']|default("stable-amd64") }}

LABEL project="{{ project }}"

# Download nginx from apt-get and clean apt-get files
RUN apt-get -y update \
  && /container/tool/add-multiple-process-stack \
  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  samba \
  proftpd \
  proftpd-mod-ldap \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

VOLUME ["/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba"]
