FROM redmine:{{ conf['docker_tag_redmine']|default("4.2.1-passenger") }}

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

COPY service/redmine/db/migrate/20200916115806_add_ldap.rb /usr/src/redmine/db/migrate/20200916115806_add_ldap.rb
COPY service/redmine/config/configuration.yml /usr/src/redmine/config/configuration.yml

COPY service/redmine/plugins/ /plugins
COPY service/redmine/themes/ /themes

RUN find /plugins -name "*.zip" -exec unzip -d /usr/src/redmine/plugins/ {} \;
RUN find /themes -name "*.zip" -exec unzip -d /usr/src/redmine/public/themes/ {} \;

RUN find /plugins -type d -exec cp -r {} /usr/src/redmine/plugins/ \;
RUN find /themes -type d -exec cp -r {} /usr/src/redmine/public/themes/ \;

WORKDIR /usr/src/redmine/

RUN BUNDLER_WITHOUT="development test" bundle install

CMD ["passenger", "start"]
