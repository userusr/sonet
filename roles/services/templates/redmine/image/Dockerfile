FROM redmine:{{ sonet_general['docker_tag_redmine']|default("4.2.1-passenger") }}

LABEL project="{{ project }}"

RUN apt-get -y update \
  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    unzip \
    build-essential \
    imagemagick \
    libmagickcore-dev \
    libmagickwand-dev ruby-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install rmagick

COPY service/redmine/plugins/ /plugins
COPY service/redmine/themes/ /themes

RUN find /plugins -maxdepth 1 -mindepth 1 -name "*.zip" -exec unzip -d /usr/src/redmine/plugins/ {} \;
RUN find /themes -maxdepth 1 -mindepth 1 -name "*.zip" -exec unzip -d /usr/src/redmine/public/themes/ {} \;

RUN find /usr/src/redmine/plugins -maxdepth 1 -mindepth 1 -type d | perl -ne 'chomp; system("mv $_ $1") if /^(.*)-(main|master|\d+\.\d+\.\d+)$/'
RUN find /usr/src/redmine/public/themes -maxdepth 1 -mindepth 1 -type d | perl -ne 'chomp; system("mv $_ $1") if /^(.*)-(main|master|\d+\.\d+\.\d+)$/'
RUN echo " ==== plugins"; cd /usr/src/redmine/plugins && find . -maxdepth 1 -mindepth 1 -type d | sort
RUN echo " ==== themes"; cd /usr/src/redmine/public/themes && find . -maxdepth 1 -mindepth 1 -type d | sort

RUN find /plugins -maxdepth 1 -mindepth 1 -type d -exec cp -r {} /usr/src/redmine/plugins/ \;
RUN find /themes -maxdepth 1 -mindepth 1 -type d -exec cp -r {} /usr/src/redmine/public/themes/ \;

RUN chown -R redmine:redmine /usr/src/redmine/public/themes/
RUN chown -R redmine:redmine /usr/src/redmine/plugins/

WORKDIR /usr/src/redmine/

RUN BUNDLER_WITHOUT="development test" bundle install

COPY service/redmine/db/migrate/20200916115806_add_ldap.rb /usr/src/redmine/db/migrate/20200916115806_add_ldap.rb
COPY service/redmine/config/configuration.yml /usr/src/redmine/config/configuration.yml

CMD ["passenger", "start"]
