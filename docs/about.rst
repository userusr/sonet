SONet
=====

SONet это шаблон, который поможет быстро развернуть набор сервисов для
командной работы с нуля, в локальной сети организации и, если нужно, offline.

SONet экономит ваше время на первоначальную настройку Redmine, GitLab, NextCloud,
внутренней почты, LDAP, DNS и reverse-proxy серверов.

Особенности
-----------

* в стек всключены: Redmine, GitLab, Mattermost, NextCloud (интергированы
  onlyoffice, drawio), почтовый сервер, Roundcube (почтовый web-клиент), "общая
  папка" доступная по SMB только для чтения и по SFTP на запись/чтение

* ваша конфигурация отделена от кода и ее можно хранить, например, в git

* в стеке есть свой сервер DNS, LDAP и reverse-proxy

* пользователи во всех сервисах уже авторизуются через LDAP

* сервисы запускаются в отдельных docker контейнерах, если что-то ненужно - можно
  выключить

* все сервисы доступны извне по HTTPS, сертификаты генерируются автоматически

* стеком легко управлять с помощью специального скрипта и ``docker-compese`` файла

* c помощью ansible сервисы можно собрать и запустить как на локальной машине,
  так и на удаленном сервере (см. :doc:`examples`)

* стек можно собрать на машине, подключенной к сети Интернет, а потом перенести
  и запустить в offline среде

Структура
---------

::

    your_sonet_config/
    │
    ├── inventory/                    <-- конфигурация
    │   ├── group_vars
    │   │   └── all
    │   │       ├── 00-vault.yml      <-- пароли пользователей
    │   │       ├── 02-settings.yml   <-- основные настройки
    │   │       ├── 05-coredns.yml    <-- параметры CoreDNS сервера и файлов DNS-зон
    │   │       ├── 10-openldap.yml   <-- пользователи и группы OpenLDAP
    │   │       ├── 15-mailserv.yml   <-- параметры почтового сервера
    │   │       ├── 20-redmine.yml    <-- параметры и плагины redmine
    │   │       ├── 25-nextcloud.yml  <-- параметры и плагины nextcloud
    │   │       └── 30-storage.yml    <-- "общая папка" и SFTP сервер
    │   │
    │   ├── host_vars                 <-- переменные, специфичные для отлельных
    │   │                                 машин, например, пароль sudo
    │   │
    │   └── inventory.yml             <-- ansible inventory (подключение к хостам)
    │
    ├── nextcloud/
    │   └── apps                      <-- дополнительные приложения для nextcloud
    │
    ├── redmine/
    │   ├── themes                    <-- дополнительные темы redmine
    │   └── plugins                   <-- дополнительные плагины redmine
    │
    ├── sonet/                        <-- SONet git submodule
    │
    ├── .env                          <-- настройки для текущего проекта
    └── playbook.yml                  <-- ansible playbook (на каких хостах и
                                          какие роли выполнять)

Весь проект можно условно разделить на конфигурацию сервисов и роли ``ansible``,
которые подготавливают docker-образы. Конфигурация представляет собой
``ansible`` playbook_ и inventory_.


.. graphviz::
    :align: center
    :alt: Схема сборки
    :caption: Схема сборки

    # https://color.romanuke.com/czvetovaya-palitra-4298/
    digraph structure {
        fontname="arial";

        node [
            shape=box,
            fontname="arial",
            fontsize=9,
            style=filled,
            fillcolor="#f1e4de"
        ];
        edge [
            color="#7c7b89"
            arrowsize=0.5
        ];
        splines="compound"

        subgraph conf {
            labeljust=r;
            labelloc=b;
            graph[style=dotted];
            fontsize = 9;
            rankdir = LR;

            playbook [ label="playbook", shape="note" ];
            inventory [ label="inventory", shape="folder" ];
        }

        ansible [ label="ansible", shape="oval" ];
        sonet_roles [ label="SONet\nroles", shape="oval" ];

        docker [ label="docker\nbuild", shape="oval" ];
        sonet_roles [ label="SONet\nroles", shape="oval", fillcolor="#f4d75e" ];

        docker_comp [ label="docker-compose", shape="oval", fillcolor="#e9723d" ];

        {rank=same; ansible sonet_roles};

        subgraph images_src {
            labeljust=r;
            labelloc=b;
            graph[style=dotted];
            fontsize = 9;
            rankdir = LR;

            redmine_img [ label="/redmine", shape="folder" ];
            openldap_img [ label="/openldap", shape="folder" ];
            mail_img [ label="/mailserv", shape="folder" ];
            comp_file [ label="docker-compose\nfile" ];

            {rank=same; redmine_img openldap_img mail_img comp_file}
        };

        subgraph images_docker {
            labeljust=r;
            labelloc=b;
            graph[style=dotted];
            fontsize = 9;
            rankdir = LR;

            redmine_docker [ label="redmine\ndocker image", shape="rect" ];
            openldap_docker [ label="openldap\ndocker image", shape="rect" ];
            mail_docker [ label="mailserv\ndocker image", shape="rect" ];

            {rank=same; redmine_docker openldap_docker mail_docker}
        };

        playbook -> ansible;
        inventory -> ansible;

        sonet_roles -> ansible;

        ansible -> redmine_img -> docker;
        ansible -> openldap_img -> docker;
        ansible -> mail_img -> docker;
        ansible -> comp_file;

        docker -> redmine_docker;
        docker -> openldap_docker;
        docker -> mail_docker;

        comp_file -> docker_comp;
        redmine_docker -> docker_comp;
        openldap_docker -> docker_comp;
        mail_docker -> docker_comp;
    }

Контейнеры на основе собранных docker-образов могут быть запущены на локальной
или удаленной машине. Запустить проект на удаленной машине можно с помощью
переменной окужения DOCKER_HOST_, `опции`_ ``-H`` (``--host``) или `docker
context`_.

.. _playbook: https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
.. _inventory: https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html
.. _DOCKER_HOST: https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
.. _`опции`: https://docs.docker.com/compose/reference/overview/
.. _`docker context`: https://docs.docker.com/engine/context/working-with-contexts/

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
