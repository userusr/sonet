# Use osixia/light-baseimage
# https://github.com/osixia/docker-light-baseimage
# https://hub.docker.com/r/osixia/light-baseimage/tags?page=1&ordering=last_updated
FROM osixia/light-baseimage:{{ sonet_general['docker_tag_mailserv_baseimage']|default("stable-amd64") }}

LABEL project="{{ project }}"

# Add vmail user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail

# Install postfix, dovecot, opendkim, clamav, spamassassin
RUN apt-get update \
    && /container/tool/add-multiple-process-stack \
    && /container/tool/add-service-available :ssl-tools \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       postfix postfix-ldap  \
       dovecot-core dovecot-imapd dovecot-lmtpd dovecot-pop3d dovecot-ldap dovecot-sieve dovecot-managesieved \
       opendkim opendkim-tools ldap-utils\
       opendmarc \
       spamassassin spamc \
       clamav clamav-base clamav-freshclam clamav-daemon clamav-milter \
       arj bzip2 cabextract cpio file gzip lzop nomarch p7zip pax rpm unrar-free unzip zip \
       ca-certificates \
    && freshclam  -v \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

ADD certs /etc/postfix/certs

# Set mails directory in a data volume
VOLUME ["/var/mail", "/data/backup"]

# Expose smtp, pop3, imap, smtp (submission), imap ssl, managesieve and dovecot replication ports
EXPOSE 25 110 143 587 993 4190 12345
