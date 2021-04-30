# SONet

_SONet_  это ansible-роли для сборки различных инструментов командной работы в один стек.

Основные особенности _SONet_:

* конфигурация хранится в отдельном репозитории
* авторизация пользователей через LDAP
* сервисы запускаются в docker контейнерах
* при необходимости генерируется собственная PKI

## Quick start

Это пример того как развернуть _SONet_ на локальной машине с тестовой
конфигурацией.

**Важно.** Эта конфигурация сделана только для примера работы и быстрого старта.
Основной смысл проекта в том, чтобы сделать свою конфигурацию под свои задачи.

Предварительно необходимо установить [docker][docker] и [docker-compose][docker-compose] на локальной машине.

В ``/etc/hosts`` нужно будет добавить имена всех сервисов, чтобы
работал reverse_proxy и можно было получить доступ к сервису по имени.

```shell
# Установить модуль venv для python
$ sudo apt install -y python3-venv

# Клонируем проект и подмодули
$ git clone https://github.com/userusr/sonet.local.git && cd sonet.local
$ git submodule init
$ git submodule update

# Для доступа к сервисам по именам и работы реверс-прокси
$ cat <<EOF | sudo tee -a /etc/hosts
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
$ make venv
$ source ./venv/bin/activate

# Собираем проект с конфигурацией по-умолчанию
$ make init && make build

# Запускаем проект
$ ./build/sonet_local/sonet up
```

Теперь можно проверить доступ.

Добавим корневой сертификат в список доверенных. Этот шаг можно пропустить, но
браузер будет каждый раз предупреждать о небезопасности страницы. Заходим на
https://pki.sonet.local, скачиваем и устанавливаем корневой сертификат
`ca.crt` в хранилище доверенных корневых центров сертификации. Перезапускам
браузер.

Заходим на https://redmine.sonet.local. Вводим логин `admin` и пароль
`admin`. Redmine попросит поменять пароль администратора - меняем. Теперь
пробуем зайти под логином пользователя из LDAP. Разлогиневаемся из-под админа и
входим как `ltolstoy` с паролем `ltolstoy`. Redmine запросит данные
пользователя из LDAP и создаст у себя такого же.

Заходим на https://mail.sonet.local. Появится страница авторизации
почтового клиента _Roundcube_. Входим как `ltolstoy` с паролем `ltolstoy`.

Заходим на https://gitlab.sonet.local. Меняем пароль пользователя `root`.
И заходим под пользователем из LDAP `ltolstoy` с паролем `ltolstoy`.

Заходим на https://mattermost.sonet.local. Выбираем "Gitbab Singl Sign-On" и
на следующей странице "Authorize". Появится интерфейс mattermost.

В FileZilla создадим новое подключение, выберем протокол `SFTP`, адрес
`storage.sonet.local`, порт 2221, логин `ltolstoy`, пароль `ltolstoy`.
Должны быть доступны две папки `public` и `library`.

В файловом менеджере подключаемся к `smb://storage.sonet.local`. Появятся те
же две папки `public` и `library`. Через `SMB` все их содержимое доступно
только для чтения.

Проверяем доступность https://excalidraw.sonet.local, если все хорошо, то
в браузере появится область для рисования.

Управлять содержимым каталога LDAP можно с помощью сервиса
https://ldapadmin.sonet.local, `Apache Directory Studio`, или других
инструментов. Чтобы авторизоваться в https://ldapadmin.sonet.local
нужно указать пользователя `cn=admin,dc=sonet,dc=local` и пароль (по умолчанию
`admin`).

Чтобы все остановить:

```shell
# Останавливаем сервисы
$ ./build/sonet_local/sonet down
$ ./build/sonet_local/sonet clean
$ ./build/sonet_local/sonet clean-images

# Удалим записи в /etc/hosts
$ sudo perl -ni.bak -e "print unless /sonet\.local/" /etc/hosts
```

[docker-compose]:https://docs.docker.com/compose/install/
[docker]:https://docs.docker.com/get-docker/
