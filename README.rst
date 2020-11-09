=====
SONet
=====

Привет! Это ``SONet`` - набор ролей Ansible_ для генерации docker-контейнеров
содержащих инструменты для командной работы. Идеи ``SONet``:

* отделить конфигурацию от кода, IaC_
* авторизация пользователей во всех сервисах через LDAP_
* сгенерировать сертификаты для всех сервисов

-----------
Quick start
-----------

.. code-block:: bash

    # Склонировать репозитории
    $ git clone git@github.com:userusr/sonet.git && cd sonet

    # Запустить локальное хранилище docker контейнеров
    $ make registry-start

    # Для доступа к сервисам по именам и работы реверс-прокси
    $ cat <<EOF | sudo tee -a /etc/hosts
    127.0.0.1 gitlab.sonet.local
    127.0.0.1 mattermost.sonet.local
    127.0.0.1 mail.sonet.local
    127.0.0.1 redmine.sonet.local
    127.0.0.1 ldapadmin.sonet.local
    127.0.0.1 pki.sonet.local
    127.0.0.1 excalidraw.sonet.local
    127.0.0.1 owncloud.sonet.local
    127.0.0.1 registry.sonet.local
    EOF

    # Собираем проект с конфигурацией по-умолчанию
    $ make init && make build && make push


    $ ./inventories/sonet.local/build/sonet_local/sonet up

.. code-block:: bash

    $ ./inventories/sonet.local/build/sonet_local/sonet down

    $ make registry-stop

------
Зачем?
------

Я как-то подумал, что не плохо было бы на работе иметь современные инструменты
для взаимодействия команды и организации сети вцелом. Денег на покупку готовых
решений никто не давал да и не нашел я того, чтобы полностью меня удовлетворило.
А хотелось многого:

* авторизацию пользователей во всех сервисах через LDAP
* внутреннюю почту и чат
* трекер задач
* сервер git

Все это можно получить установив OpenLDAP_, GitLab_, RedMine_ и т. д. И я так и
сделал. И все бы ничего, но пришло время менять работу и там, угадайте, все
пришлось начинать сначала. Хватит, подумал я, и решил все автоматизировать.

Инфраструктура должна настраиваться из кода, т.е. IaC_. По крайней мере на
первых этапах. Для этого я выбрал Ansible_. Я уже работал с puppet_  но Ansible_
подкупил свой clientless архитектурой, языком Python_ и шаблонизатором Jinja_
под капотом.

Инфраструктура должна быть переносимой. По началу, я планировал написать роли
Ansible для настройки серверов или виртуальных машин. Но тогда пришлось бы на
время разработки держать все виртуальные машины у себя на ноутбуке, настраивать
между ними сеть, следить за обновлением операционной системы. Ну и все это
выглядело громоздко. Я решил, что docker лучше подойдет для этой задачи.

Большинство необходимого ПО уже есть в docker и это существенно облегчает
задачу. Для GitLab, CoreDNS, Roundcube есть официально поддерживаемые
репозитории (`gitlab/gitlab-ce`_, `coredns/coredns`_,
`roundcube/roundcubemail`_)

.. Рассказать о docker_host

Осталось только настроить нужные сервисы и сгенерировать docker-compose файл.
Этим и займемся.

Сейчас в ``SONet`` входят:

* CoreDNS_ - сервер DNS_
* Caddy_ - сервер `HTTP/2`_ и `reverse proxy`_ к внутренним ресурсам
* OpenLDAP_ - сервер LDAP_
* phpLDAPadmin_ - WEB-интерфейс для управления LDAP
* Postfix_ - Dovecot_ -- почтовый сервер
* Roundcube_ - WEB-клиент почты
* GitLab_ - сервер git_ и `CI/CD`_
* RedMine_ - управление проектами
* Excalidraw_ - доска для рисунков "от руки"

---

.. _CoreDNS: https://coredns.io/
.. _DNS: https://en.wikipedia.org/wiki/Domain_Name_System
.. _OpenLDAP: https://www.openldap.org/
.. _LDAP: https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
.. _Caddy: https://caddyserver.com/
.. _`HTTP/2`: https://en.wikipedia.org/wiki/HTTP/2
.. _`reverse proxy`: https://en.wikipedia.org/wiki/Reverse_proxy
.. _phpLDAPadmin: http://phpldapadmin.sourceforge.net/wiki/index.php/Main_Page
.. _Roundcube: https://roundcube.net/
.. _GitLab: https://about.gitlab.com/
.. _git: https://en.wikipedia.org/wiki/Git
.. _`CI/CD`: https://en.wikipedia.org/wiki/CI/CD
.. _RedMine: https://www.redmine.org/
.. _Postfix: http://www.postfix.org/
.. _Dovecot: https://www.dovecot.org/
.. _Excalidraw: https://excalidraw.com/
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
