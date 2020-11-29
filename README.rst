=====
SONet
=====

Привет! Это ``SONet`` - набор инструментов для командной работы. Конфигурация
осуществляется с помощью  Ansible_, пользователи авторизуются через LDAP_, а
сервисы запускаются как docker контейнеры.

Идеи ``SONet``:

* отделить конфигурацию от кода, IaC_
* авторизовывать пользователей во всех сервисах через LDAP_
* запускать все сервисы в docker контейнерах
* сгенерировать сертификаты для всех сервисов

-----------
Quick start
-----------

.. image:: https://raw.githubusercontent.com/userusr/sonet/docs/docs/_static/quickstart_dia.png

Это пример того как развернуть SONet на локальной машине с тестовой
конфигурацией. В ``/etc/hosts`` нужно будет добавить имена всех сервисов. Это
нужно для того, чтобы работал reverse_proxy и можно было получить доступ к
сервису по имени.

Предварительно нужно установить docker_ и docker-compose_ на локальной машине.

.. code-block:: bash

    # Установить модуль venv для python
    sudo apt install -y python3-venv

    # Склонировать репозитории
    git clone git@github.com:userusr/sonet.git && cd sonet

    # Для доступа к сервисам по именам и работы реверс-прокси
    cat <<EOF | sudo tee -a /etc/hosts
    127.0.0.1 pki.sonet.local
    127.0.0.1 ldapadmin.sonet.local
    127.0.0.1 redmine.sonet.local
    127.0.0.1 mail.sonet.local
    127.0.0.1 gitlab.sonet.local
    127.0.0.1 mattermost.sonet.local
    127.0.0.1 storage.sonet.local
    127.0.0.1 excalidraw.sonet.local
    EOF

    # Создаем виртуальное окружение и устанавливаем зависимости
    make venv
    source ./venv/bin/activate

    # Собираем проект с конфигурацией по-умолчанию
    make init && make build

    # Запускаем проект
    ./inventories/sonet.local/build/sonet_local/sonet up

.. _docker-compose: https://docs.docker.com/compose/install/
.. _docker: https://docs.docker.com/get-docker/

Теперь можно проверить доступ.

Добавим корневой сертификат в список доверенных. Этот шаг можно пропустить, но
браузер будет каждый раз предупреждать о небезопасности страницы. Заходим на
``https://pki.sonet.local``, скачиваем и устанавиваем корневой сертификат
``ca.crt`` в хранилище доверенных корневых центров сертификации. Перезапускаем
браузер.

Заходим на ``https://redmine.sonet.local``. Вводим логин ``admin`` и пароль
``admin``. Redmine попросит поменять пароль администратора - меняем. Теперь
пробуем зайти под логином пользователя из LDAP. Разлогиневаемся из под админа и
входим как ``ltolstoy`` с паролем ``ltolstoy``. Redmine запросит данные
пользователя из LDAP и создаст у себя такого же.

Заходим на ``https://mail.sonet.local``. Должна появиться страница авторизации
почтового клиента Roundcube_. Входим как ``ltolstoy`` с паролем ``ltolstoy``.

Заходим на ``https://gitlab.sonet.local``. Меняем пароль пользователя ``root``.
И заходим под пользователем из LDAP ``ltolstoy`` с паролем ``ltolstoy``.

Заходим на ``https://mattermost.sonet.local``. Выбираем "Gitbab Singl Sign-On" и
на следующей странице "Authorize". Должен появиться интерфейс mattermost.

В FileZilla создадим новое подключение, выберем протокол ``SFTP``, адрес
``storage.sonet.local``, порт 2221, логин ``ltolstoy``, пароль ``ltolstoy``.
Должны быть доступны две папки ``public`` и ``library``.

В файловом менеджере подключаемся к ``smb://storage.sonet.local`` должны
появиться те же две папки ``public`` и ``library``. Через ``SMB`` все их
содержимое доступно только для чтения.

Проверяем доступность ``https://excalidraw.sonet.local``, если все хорошо, то
в браузере должна появиться область для рисования.

Управлять содержимым каталога LDAP можно с помощью сервиса
``https://ldapadmin.sonet.local``, `Apache Directory Studio`_, или других
инструментов. Чтобы авторизоваться в ``https://ldapadmin.sonet.local``
нужно указать пользователя ``cn=admin,dc=sonet,dc=local`` и пароль (по-умолчанию
``admin``).

Чтобы все остановить нужно:

.. code-block:: bash

    # Останавливаем сервисы
    ./inventories/sonet.local/build/sonet_local/sonet down
    ./inventories/sonet.local/build/sonet_local/sonet clean
    ./inventories/sonet.local/build/sonet_local/sonet clean-images

    # Удалим записи в /etc/hosts
    sudo perl -ni.bak -e "print unless /sonet\.local/" /etc/hosts

.. _`Apache Directory Studio`: https://directory.apache.org/studio/

**Важно.** Эта конфигурация сделана только для примера работы и быстрого старта.
Основной смысл проекта как раз в том, чтобы сделать свою конфигурацию под свои
задачи.

---------
Структура
---------

Весь проект можно условно разделить на конфигурацию сервисов и роли ``ansible``,
которые подготавливают docker-образы. Конфигурация представляет собой
``ansible`` playbook_ и inventory_. Контейнеры на основе собранных
docker-образов могут быть запущены на локальной или удаленной машине.

Запустить проект на удаленной машине можно с помощью переменной окужения
DOCKER_HOST_, `опции`_ ``-H`` (``--host``) или `docker context`_.

.. _playbook: https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
.. _inventory: https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html

Сейчас в ``SONet`` входят:

* `coredns/coredns`_ - сервер DNS_ CoreDNS_
* `docker/caddy`_ - сервер `HTTP/2`_ и `reverse proxy`_ к внутренним ресурсам
* `osixia/docker-openldap`_ - cервер OpenLDAP_
* `osixia/docker-phpLDAPadmin`_ - управление LDAP
* почтовый сервер на основе `osixia/docker-mmc-mail`_
* `roundcube/roundcubemail`_ - WEB-клиент почты
* `gitlab/gitlab-ce`_ - GitLab
* `docker/redmine`_ - Redmine
* `excalidraw/excalidraw`_ - доска для рисунков "от руки"
* общая папка доступная по SMB только для чтения и по SFTP на запись/чтение

.. _DOCKER_HOST: https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
.. _`опции`: https://docs.docker.com/compose/reference/overview/
.. _`docker context`: https://docs.docker.com/engine/context/working-with-contexts/

------
Зачем?
------

Я как-то подумал, что не плохо было бы на работе иметь современные инструменты
для взаимодействия команды и организации сети вцелом. Необходимо было обеспечить:

* авторизацию пользователей во всех сервисах через LDAP
* разделение прав пользователей на сервисы на основе LDAP групп
* внутреннюю почту, чат, трекер задач, сервер git
* свою инфраструктуру PKI

Все это можно получить установив OpenLDAP_, GitLab_, RedMine_ и т. д. И я так и
сделал. И все бы ничего, но пришло время менять работу и там, угадайте, все
пришлось начинать сначала. Так и пришла идея сделать ``SONet``.

Инфраструктура должна настраиваться из кода, т.е. IaC_. По крайней мере на
первых этапах. Для этого я выбрал Ansible_. Я уже работал с puppet_  но Ansible_
подкупил свой clientless архитектурой, языком Python_ и шаблонизатором Jinja_
под капотом.

Инфраструктура должна быть переносимой. По началу, я планировал написать роли
``ansible`` для настройки серверов или виртуальных машин. Но тогда пришлось бы на
время разработки держать все виртуальные машины у себя на ноутбуке, настраивать
между ними сеть, следить за обновлением операционной системы. Ну и все это
выглядело громоздко. Я решил, что docker лучше подойдет для этой задачи.

Большинство необходимого ПО уже есть в docker и это существенно облегчает
задачу. Для GitLab, CoreDNS, Roundcube есть официально поддерживаемые
репозитории (`gitlab/gitlab-ce`_, `coredns/coredns`_,
`roundcube/roundcubemail`_). Осталось только настроить нужные сервисы и
сгенерировать docker-compose файл.

.. _CoreDNS: https://coredns.io/
.. _DNS: https://en.wikipedia.org/wiki/Domain_Name_System
.. _OpenLDAP: https://www.openldap.org/
.. _LDAP: https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
.. _`HTTP/2`: https://en.wikipedia.org/wiki/HTTP/2
.. _`reverse proxy`: https://en.wikipedia.org/wiki/Reverse_proxy
.. _Roundcube: https://roundcube.net/
.. _GitLab: https://about.gitlab.com/
.. _git: https://en.wikipedia.org/wiki/Git
.. _`CI/CD`: https://en.wikipedia.org/wiki/CI/CD
.. _RedMine: https://www.redmine.org/
.. _Ansible: https://www.ansible.com/
.. _puppet: https://puppet.com/
.. _Python: https://www.python.org/
.. _Jinja: https://jinja.palletsprojects.com
.. _IaC: https://en.wikipedia.org/wiki/Infrastructure_as_code
.. _`osixia/docker-mmc-mail`: https://github.com/osixia/docker-mmc-mail
.. _`osixia/docker-openldap`: https://github.com/osixia/docker-openldap
.. _`osixia/docker-phpLDAPadmin`: https://github.com/osixia/docker-phpLDAPadmin
.. _`excalidraw/excalidraw`: https://github.com/excalidraw/excalidraw
.. _`gitlab/gitlab-ce`: https://hub.docker.com/r/gitlab/gitlab-ce/
.. _`docker/caddy`: https://hub.docker.com/_/caddy
.. _`coredns/coredns`: https://hub.docker.com/r/coredns/coredns/
.. _`roundcube/roundcubemail`: https://hub.docker.com/r/roundcube/roundcubemail/
.. _`docker/redmine`: https://hub.docker.com/_/redmine
