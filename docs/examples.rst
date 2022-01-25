Примеры развертывания
=====================

"Все в одном" на локальной машине
---------------------------------

Это пример того как развернуть *SONet* на локальной машине с тестовой
конфигурацией.

.. _`установить docker`:

#.  установим docker_ и docker-compose_ на локальной машине

    .. _docker-compose: https://docs.docker.com/compose/install/
    .. _docker: https://docs.docker.com/get-docker/

#.  в ``/etc/hosts`` добавим имена всех сервисов, чтобы работал reverse_proxy и
    можно было получить доступ к сервису по имени

    .. code-block:: bash

        cat <<EOF | sudo tee -a /etc/hosts
        127.0.0.1 pki.sonet.local
        127.0.0.1 ldapadmin.sonet.local
        127.0.0.1 redmine.sonet.local
        127.0.0.1 mail.sonet.local
        127.0.0.1 gitlab.sonet.local
        127.0.0.1 mattermost.sonet.local
        127.0.0.1 storage.sonet.local
        127.0.0.1 excalidraw.sonet.local
        127.0.0.1 nextcloud.sonet.local
        127.0.0.1 onlyoffice.sonet.local
        127.0.0.1 drawio.sonet.local
        127.0.0.1 portainer.sonet.local
        EOF

#.  клонируем проект и подмодули

    .. code-block:: bash

        git clone https://github.com/userusr/sonet.local.git
        cd sonet.local
        git submodule init
        git submodule update

#.  установим модуль venv для python

    .. code-block:: bash

        sudo apt install -y python3-venv

#.  создаем виртуальное окружение и устанавливаем зависимости

    .. code-block:: bash

        make venv
        source ./venv/bin/activate

#.  собираем проект с конфигурацией по-умолчанию

    .. code-block:: bash

        make init && make build

#.  запускаем проект

    .. code-block:: bash

        ./build/sonet_local/sonet up

#.  проверим, все ли работает:

    Добавим корневой сертификат в список доверенных. Этот шаг можно пропустить, но
    браузер будет каждый раз предупреждать о небезопасности страницы. Заходим на
    https://pki.sonet.local, скачиваем и устанавливаем корневой сертификат
    ``ca.crt`` в хранилище доверенных корневых центров сертификации. Перезапускам
    браузер.

    Заходим на https://redmine.sonet.local. Вводим логин ``admin`` и пароль
    ``admin``. Redmine попросит поменять пароль администратора - меняем. Теперь
    пробуем зайти под логином пользователя из LDAP. Разлогиневаемся из-под админа и
    входим как ``lpervov`` с паролем ``lpervov``. Redmine запросит данные
    пользователя из LDAP и создаст у себя такого же.

    Заходим на https://nextcloud.sonet.local. Вводим логин ``admin`` и пароль
    ``nextcloud``. Nextcloud так же уже подключен к LDAP и можно авторизоваться как
    ``lpervov`` с паролем ``lpervov``. В Nextcloud настроена интеграция с onlyoffice и drawio, которые так же работают в docker контейнерах.

    Заходим на https://mail.sonet.local. Появится страница авторизации
    почтового клиента Roundcube. Входим как ``lpervov`` с паролем ``lpervov``.

    Заходим на https://gitlab.sonet.local. Меняем пароль пользователя ``root``.
    И заходим под пользователем из LDAP ``lpervov`` с паролем ``lpervov``.

    Заходим на https://mattermost.sonet.local. Выбираем "Gitbab Singl Sign-On" и
    на следующей странице "Authorize". Появится интерфейс mattermost.

    В FileZilla создадим новое подключение, выберем протокол ``SFTP``, адрес
    ``storage.sonet.local``, порт 2221, логин ``lpervov``, пароль ``lpervov``.
    Должны быть доступны две папки ``public`` и ``library``.

    В файловом менеджере подключаемся к ``smb://storage.sonet.local``. Появятся те
    же две папки ``public`` и ``library``. Через ``SMB`` все их содержимое доступно
    только для чтения.

    Проверяем доступность https://excalidraw.sonet.local, если все хорошо, то
    в браузере появится область для рисования.

    Управлять запущенными контейнерами можно через интерфейс Portainer, доступный
    тут http://portainer.sonet.local. Пользователь для входа ``admin`` и пароль
    ``portainer``. Portainer так же поддерживает_ аутентификацию пользователей через
    LDAP, но подключить docker образ с помощью переменных окружения к LDAP `пока
    нельзя`_.

    Управлять содержимым каталога LDAP можно с помощью сервиса
    https://ldapadmin.sonet.local, ``Apache Directory Studio``, или других
    инструментов. Чтобы авторизоваться в https://ldapadmin.sonet.local
    нужно указать пользователя ``cn=admin,dc=sonet,dc=local`` и пароль (по умолчанию
    ``admin``).

    .. _поддерживает: https://documentation.portainer.io/v2.0/auth/ldap/
    .. _`пока нельзя`: https://github.com/portainer/portainer/issues/3125

#.  остановим все

    .. code-block:: bash

        ./build/sonet_local/sonet down
        ./build/sonet_local/sonet clean
        ./build/sonet_local/sonet clean-images

#.  удалим записи в ``/etc/hosts``

    .. code-block:: bash

        sudo perl -ni.bak -e "print unless /sonet\.local/" /etc/hosts

.. _`Cервер в локальной сети`:

Cервер в локальной сети
-----------------------

*Задача*: развернуть все сервисы на сервере, расположенном в локальной сети
организации.

Будем использовать DNS и LDAP из SONet.

:ref:`Тестовый стенд <example_1>`.

.. graphviz::
    :align: center

    graph g001 {
        fontname="arial";

        node [
            shape=box,
            fontname="arial",
            fontsize=9,
            style=filled,
            fillcolor="#f1e4de"
        ];
        splines="compound"

        inet [
            label="The Internet",
            shape=none,
            image="_static/cloud.png",
            color="#ffffff",
            fillcolor="#ffffff"
        ];

        subgraph cluster_level1 {
            label ="Предприятие";
            labeljust=l;
            labelloc=b;
            graph[style=dotted];
            fontsize = 9;
            rankdir = LR;

            workspace [
                label="Рабочее место\nадминистратора\n\nIP: 192.168.15.250\nDNS: 192.168.15.101"
            ];

            user1 [
                label="Рабочее место\nпользователя\n\nIP: 192.168.15.1\nDNS: 192.168.15.101"
            ];

            server [ label="Сервер\n\nIP: 192.168.15.101" ];

            local_lan [
                label="Локальная сеть\nпредприятия\n192.168.15.0/24",
                shape=none,
                image="_static/cloud.png",
                color="#ffffff",
                fillcolor="#ffffff"
            ];
            {rank=same; workspace; local_lan; server}
        }

        inet -- server [style=dashed];
        inet -- workspace [style=dashed];
        workspace -- local_lan -- server;
        local_lan -- user1;
    }

.. list-table:: Основные параметры
    :widths: 15 10 30
    :header-rows: 1

    *   - Параметр
        - Значение
        - Описание
    *   - Организация
        - *Cool Factory*
        - название нашей вымышленной организации
    *   - папка проекта
        - ``/home/user/cool_factory``
        - папка, куда :ref:`клонируем <клонируем sonet.local>` ``sonet.local``
    *   - ``domain``
        - ``cool.factory``
        - Доменное имя
    *   - ``ldap_base_dn``
        - ``dc=cool,dc=factory``
        - LDAP


#.  установим docker_ и docker-compose_ на сервере

#.  установим *git* и *python3-venv* на машине администратора

    .. code-block:: bash

        sudo apt install git python3-venv

#.  убедимся, что с машины администратора можно зайти по ssh на сервер без пароля

#.  клонируем проект и подмодули в папку ``cool_factory``:

    .. _`клонируем sonet.local`:

    .. code-block:: bash

        git clone https://github.com/userusr/sonet.local.git cool_factory
        cd cool_factory
        git submodule init
        git submodule update

#.  создаем виртуальное окружение и устанавливаем зависимости

    .. code-block:: bash

        make venv
        source ./venv/bin/activate

#.  создаем отдельную ветку для нашей конфигурации

    .. code-block:: bash

        git checkout -b cool_factory

#.  по желанию, копируем настройки VSCode

    .. code-block:: bash

        cp -r .vscode.example .vscode

#.  копируем файл с переменными окружения

    .. code-block:: bash

        cp .env.sample .env

#.  редактируем файл ``.env``

    .. code-block:: txt

        cat > .env <<HERE
        ## Project instance name
        PROJECT=cool_factory

        ## Vault password
        ANSIBLE_VAULT_PASSWORD=secret_password
        HERE

    .. _`пароли учетных записей`:

#.  Поменяем пароли почтовых аккаунтов ``redmine``, ``gitlab``, ``nextcloud``, а
    так же пользователей LDAP.

    Пароли находятся в файле ``./inventory/group_vars/all/00-vault.yml``. Они
    ззаписаны в формате зашифровенных строк  *ansible vault*. Чтобы их поменять,
    нужно вызвать следующие команды.

    .. code-block:: bash

        source .env; export ANSIBLE_VAULT_PASSWORD

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_ldap_admin_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_ldap_config_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_ldap_readonly_user_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_redmine_admin_mail_account_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_gitlab_mail_account_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_gitlab_root_account_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_nextcloud_admin_mail_account_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_ldap_user_default_password' \
            >> ./inventory/group_vars/all/00-vault.yml.tmp

        mv ./inventory/group_vars/all/00-vault.yml.tmp ./inventory/group_vars/all/00-vault.yml

#.  В файле ``./inventory/group_vars/all/02-settings.yml`` поменяем пароль для
    пользователя ``admin`` для сервиса ``portainer``. Он записывается в виде хеша
    ``htpasswd`` в переменной ``portainer_admin_account_password``. Генерируем хэш
    командой ниже и вставляем на место того, который уже написан в конфиге:

    .. code-block:: bash

        sudo apt install apache2-utils

        portainer_admin_pass_hash=$(htpasswd -nbB admin 'change_me') \
            | cut -d ":" -f 2 | sed 's/\$/\$\$/g'

        perl -ne "s/^(\s*portainer_admin_account_password:).*\$/\$1 \'\$ENV{'portainer_admin_pass_hash'}\'/g" \
            ./inventory/group_vars/all/02-settings.yml

#.  Поменяем доменное имя в файле ``./inventory/group_vars/all/02-settings.yml``:

    .. code-block:: bash

        domain: "cool.factory"

#.  В стеке будет работать DNS сервер *coredns*. Он будет обслуживать одну зону
    нашего домена. Его настройки находятся в файле
    ``./inventory/group_vars/all/05-coredns.yml``. В нем описаны две зоны для
    прямого и обратного просмотра. Так как все сервисы находятся на одном хосте,
    то они все ссылаются на один и тот же ip-адрес.

    .. code-block:: yaml

        coredns:
          zones:
            - zonefile: "{{ conf['domain'] }}.zone"
              name: "{{ conf['domain'] }}"
              domain_name: "@"
              name_server_fqdn: "ns.{{ conf['domain'] }}."
              admin_email: "root@ns.{{ conf['domain'] }}."
              members:
                - { hostname: '@', type: 'NS', address: "ns.{{ conf['domain'] }}." }
                - { hostname: '', type: 'MX', address: "10 mail.{{ conf['domain'] }}." }
                - { hostname: "ns.{{ conf['domain'] }}.", type: 'A', address: '192.168.15.101' }
                - { hostname: "{{ conf['ldap_hostname'] }}.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "mail.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "gitlab.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "mattermost.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "redmine.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "ldapadmin.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "storage.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "pki.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "excalidraw.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "owncloud.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "nextcloud.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "onlyoffice.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "drawio.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "portainer.{{ conf['domain'] }}.", type: 'CNAME', address: "ns.{{ conf['domain'] }}." }
            - zonefile: '15.168.192.in-addr.arpa.zone'
              name: '15.168.192.in-addr.arpa'
              domain_name: "@"
              name_server_fqdn: "ns.{{ conf['domain'] }}."
              admin_email: "root@ns.{{ conf['domain'] }}."
              members:
                - { hostname: '@', type: 'NS', address: "ns.{{ conf['domain'] }}." }
                - { hostname: "ns.{{ conf['domain'] }}.", type: 'PTR', address: '192.168.15.101' }

#.  все сервисы авторизуют пользоватей через LDAP. Будем использовать внутренний
    сервер *openldap*. В файле ``./inventory/group_vars/all/10-openldap.yml``
    поменяем следующие параметры:

    .. code-block:: bash

        ldap_organisation: "Cool Factory"
        ldap_base_dn: "dc=cool,dc=factory"

    Возможные значения параметра ``ldap_log_level`` перечислены в `таблице 5.1`_.

    .. _`таблице 5.1`: https://www.openldap.org/doc/admin24/slapdconf2.html

#.  Далее нужно прописать, какие пользователи будут созданы в LDAP. Это только
    первоначальная настройка, в ходе работы пользователей можно будет менять как
    это будет требоваться.

    Вместе с пользователями создаются несколько групп, они нужны для контроля
    доступа к сервисам ``redmine_users``, ``gitlab_users``, ``nextcloud_users`` и
    ``storage_admins``. Члены групп ```redmine_users``, ``gitlab_users``,
    ``nextcloud_users`` могут заходить на соответствующие сервисы, а члены группы
    ``storage_admins`` могут заходить на общий ресурс `storage` по протоколу SFTP
    для управления данными.

    Так же создаются служебные учетные записи ``redmine``, ``gitlab`` и
    ``nextcloud`` для отправки почты с соответствующих сервисов.

    .. _docker-openldap: https://github.com/osixia/docker-openldap

#.  Создадим файл ``./inventory/host_vars/acd_server/vault.yml`` с паролем
    ``sudo`` от удаленного сервера, на котором будем запускать стек:

    .. note::

        *server* - название сервера в ``./inventory/inventory.yml``

    .. code-block:: bash

        mkdir -p ./inventory/host_vars/server

        ansible-vault encrypt_string --vault-password-file ./sonet/tools/vault-env-client.py \
            'change_me' --name 'vault_server_become_password' \
            > ./inventory/host_vars/server/vault.yml

#.  Редактируем ``./inventory/inventory.yml``. Список ``include_service`` содержит
    те сервисы, которые нужно развернуть в этой установке.

    .. code-block:: yaml

        all:
          hosts:
            # Удаленный сервер
            server:
              ansible_connection: ssh
              ansible_host: 192.168.15.101
              ansible_become: true
              ansible_python_interpreter: python3
              ansible_become_password: "{{ vault_server_become_password }}"
              backup_path: "/opt/{{ project }}/backup"
              build_path: "/opt/{{ project }}/build"
              docker_data_path: "/opt/{{ project }}/data"
              generate_service_certs: true
              include_service:
                - caddy
                - coredns
                - openldap
                - phpldapadmin
                - redmine
                - excalidraw
                - gitlab
                - roundcube
                - mailserv
                - storage
                - nextcloud
                - portainer

#.  В файл ``playbook.yml`` добавляем:

    .. code-block:: yaml

        - name: Deploy on server
          hosts: "server"
          roles:
            - role: './sonet/roles/services'
            - role: './sonet/roles/generate_compose'

#.  Собираем проект

    .. code-block:: bash

        make init
        make build

#.  Переходим на сервер и запускаем весь стек

    .. code-block:: bash

        cd /opt/cool_factory/build
        ./cool_factory up

#.  На рабочем месте пользователя проверяем доступ к сервисам

    * https://pki.cool.factory
    * https://redmine.cool.factory
    * https://nextcloud.cool.factory
    * https://mail.cool.factory
    * https://gitlab.cool.factory
    * https://mattermost.cool.factory

#.  Остановить все можно командой

    .. code-block:: bash

        ./cool_factory down
