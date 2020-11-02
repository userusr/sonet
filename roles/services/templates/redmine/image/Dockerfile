FROM redmine:4.1.1-passenger

LABEL project="{{ project }}"

RUN apt-get -y update \
  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    build-essential \
    imagemagick \
    libmagickcore-dev \
    libmagickwand-dev ruby-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install rmagick

# The gitmike theme can be retrieved from its project page
# Hide Sidebar plugin allows to hide the sidebar. Especially useful when editing issues
# and Clipboard Image Paste allows to attach an image pasting from the clipboard instead of selecting a file
RUN git clone https://github.com/makotokw/redmine-theme-gitmike.git public/themes/gitmike \
    && git clone https://github.com/fraoustin/RTMaterial.git public/themes/RTMaterial \
    && git clone https://gitlab.com/bdemirkir/sidebar_hide.git plugins/sidebar_hide \
    && git clone https://github.com/RubyClickAP/clipboard_image_paste.git plugins/clipboard_image_paste

COPY service/redmine/db/migrate/20200916115806_add_ldap.rb /usr/src/redmine/db/migrate/20200916115806_add_ldap.rb
COPY service/redmine/config/configuration.yml /usr/src/redmine/config/configuration.yml

COPY service/redmine/plugins/ /plugins
COPY service/redmine/themes/ /themes

RUN find /plugins -name "*.zip" -exec unzip -d /usr/src/redmine/plugins/ {} \;
RUN find /themes -name "*.zip" -exec unzip -d /usr/src/redmine/public/themes/ {} \;

RUN cd /usr/src/redmine/ && bundle install --without development test

CMD ["passenger", "start"]
