Тестовые стенды
===============

.. _example_1:

Cервер в локальной сети
-----------------------

Сделаем тестовую среду для проверки работоспособности конфигурации SONet для
сервера в :ref:`локальной сети предприятия <Cервер в локальной сети>`.
Виртуальные машины будут на VirtualBox. У сервера и рабочего
места администратора будет выход в Интернет через NAT интерфейс VirtualBox,
а у рабочего места пользователя - только доступ ко  внутренней сети *intnet*.

.. graphviz::
    :align: center

    graph scheme1 {
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
        ];

        inet [
            label="The Internet",
            shape=none,
            image="_static/cloud.png",
            color="#ffffff",
            fillcolor="#ffffff"
        ];

        subgraph cluster_level1 {
            label ="VirtualBox Host";
            labeljust=l;
            labelloc=b;
            graph[style=dotted];
            fontsize = 9;
            rankdir = LR;

            workspace [
                label="{<f0> Рабочее место\nадминистратора|<f1>NAT|<f2> intnet\nIP: 192.168.15.250\nDNS: 192.168.15.101}",
                shape=record
            ];

            user [
                label="{<f0> Рабочее место\nпользователя|<f1> intnet\nIP: 192.168.15.1\nDNS: 192.168.15.101}",
                shape=record
            ];

            server [
                label="{<f0> Сервер|<f1>NAT|<f2> intnet\nIP: 192.168.15.101\nDNS: 192.168.15.101}",
                shape=record
            ];

            local_lan [
                label="intnet\n192.168.15.0/24",
                shape=none,
                image="_static/cloud.png",
                color="#ffffff",
                fillcolor="#ffffff"
            ];

            {rank=same; workspace; local_lan; server}
        }

        inet -- server:f1;
        inet -- workspace:f1;
        workspace:f2 -- local_lan -- server:f2;
        local_lan -- user:f1;
    }

Сервер
~~~~~~

Сервер будет работать на `Ubuntu 20.04`_.

.. _`Ubuntu 20.04`: https://ubuntu.com/download/server

#.  создаем виртуальную машину:

    .. code-block:: bash

        SERVER_ISO="VirtualBox VMs/ISO/ubuntu-20.04.2-live-server-amd64.iso"
        SERVER_VM='sonet_local_server'
        SERVER_MEDIUM="$HOME/VirtualBox VMs/$SERVER_VM/$SERVER_VM.vdi"

        VBoxManage createvm --name "$SERVER_VM" --ostype "Ubuntu_64" --register

        VBoxManage modifyvm "$SERVER_VM" --description "ubuntu_sonet_local_lan"

        VBoxManage createhd --filename "$SERVER_MEDIUM" --size 32768

        VBoxManage storagectl "$SERVER_VM" --name "SATA Controller" --add sata \
        --controller IntelAHCI

        VBoxManage storageattach "$SERVER_VM" --storagectl "SATA Controller" --port 0 \
        --device 0 --type hdd --medium "$SERVER_MEDIUM"

        VBoxManage storagectl "$SERVER_VM" --name "IDE Controller" --add ide

        VBoxManage storageattach "$SERVER_VM" --storagectl "IDE Controller" --port 0 \
        --device 0 --type dvddrive --medium "$SERVER_ISO"

        VBoxManage modifyvm "$SERVER_VM" --ioapic on

        VBoxManage modifyvm "$SERVER_VM" --boot1 dvd --boot2 disk --boot3 none --boot4 none

        VBoxManage modifyvm "$SERVER_VM" --memory 4096 --vram 128

        VBoxManage modifyvm "$SERVER_VM" --nic2 intnet

        VBoxManage modifyvm "$SERVER_VM" --intnet2 "sonet_local_lan"

        # Port forwarding 3223 for ssh
        VBoxManage modifyvm "$SERVER_VM" --natpf1 "guestssh,tcp,,3223,,22"

#.  запускаем VM

    .. code-block:: bash

        VBoxManage startvm "$SERVER_VM"

    Так же VM можно запустить в *headless* режие и подключаться к ней по VNC

    .. code-block:: bash

        # enable VNC server on port 3389
        VBoxManage modifyvm "$SERVER_VM" --vrde on
        # set VNC password
        VBoxManage modifyvm "$SERVER_VM" --vrdeproperty VNCPassword=secret
        VBoxHeadless -s "$SERVER_VM"

#.  устанавливаем операционную систему, сразу настраиваем IP адрес на внутренней
    сети и устанавливаем openssh-server

#.  настраиваем авторизацию и прописываем ssh alias

    .. code-block:: bash

        ssh-copy-id -p 3223 -o IdentitiesOnly=yes -i ~/.ssh/id_rsa user@localhost

        cat >> ~/.ssh/config <<HERE
        Host "$SERVER_VM"
            User user
            HostName localhost
            Port 3223
            IdentityFile ~/.ssh/id_rsa.pub
            IdentitiesOnly yes
        HERE

    Проверим подключение к VM:

    .. code-block:: bash

        ssh $SERVER_VM

#.  устанавливаем docker и docker-compose на сервере (все команды выполняем на VM)

    .. code-block:: bash

        cat >> install_docker <<HERE
        #!/usr/bin/env bash
        set -Eeuo pipefail

        # https://github.com/docker/compose/releases
        compose_version="1.29.1/docker-compose-$(uname -s)-$(uname -m)"

        sudo apt-get update

        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl gnupg-agent software-properties-common

        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

        sudo apt-get update

        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        sudo usermod -aG docker ${USER}

        sudo curl -L \
            "https://github.com/docker/compose/releases/download/$compose_version" \
            -o /usr/local/bin/docker-compose

        sudo chmod +x /usr/local/bin/docker-compose
        HERE

        bash install_docker

#.  установим дополнения VirtualBox для операционной системы

    .. code-block:: bash

        VBoxManage storageattach "$SERVER_VM" --storagectl "IDE Controller" --port 0 \
            --device 0 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso

   на сервере выполним команды

    .. code-block:: bash

        sudo mount /dev/cdrom /media && sudo /media/VBoxLinuxAdditions.run

        sudo shutdown -h now

#.  сделаем на всякий случай snapshort

    .. code-block:: bash

        VBoxManage snapshot "$SERVER_VM" take installer_finished

#.  приостановить работы VM и сохранив при этом ее состояние можно командой

    .. code-block:: bash

        VBoxManage controlvm "$SERVER_VM" savestate

Рабочее место администратора
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Для рабочей станции администратора будем использовать `Linux Mint`_.

.. _`Linux Mint`: https://linuxmint.com/download.php

#.  создаем виртуальную машину:

    .. code-block:: bash

        ADM_WSP_ISO="VirtualBox VMs/ISO/linuxmint-20-xfce-64bit.iso"
        ADM_WSP_VM='sonet_local_adm'
        ADM_WSP_MEDIUM="$HOME/VirtualBox VMs/$ADM_WSP_VM/$ADM_WSP_VM.vdi"

        VBoxManage createvm --name "$ADM_WSP_VM" --ostype "Ubuntu_64" --register

        VBoxManage modifyvm "$ADM_WSP_VM" --description "sonet_local_worksp"

        VBoxManage createhd --filename "$ADM_WSP_MEDIUM" --size 32768

        VBoxManage storagectl "$ADM_WSP_VM" --name "SATA Controller" --add sata \
        --controller IntelAHCI

        VBoxManage storageattach "$ADM_WSP_VM" --storagectl "SATA Controller" --port 0 \
        --device 0 --type hdd --medium "$ADM_WSP_MEDIUM"

        VBoxManage storagectl "$ADM_WSP_VM" --name "IDE Controller" --add ide

        VBoxManage storageattach "$ADM_WSP_VM" --storagectl "IDE Controller" --port 0 \
        --device 0 --type dvddrive --medium "$ADM_WSP_ISO"

        VBoxManage modifyvm "$ADM_WSP_VM" --ioapic on

        VBoxManage modifyvm "$ADM_WSP_VM" --boot1 dvd --boot2 disk --boot3 none --boot4 none

        VBoxManage modifyvm "$ADM_WSP_VM" --memory 4096 --vram 128

        VBoxManage modifyvm "$ADM_WSP_VM" --nic2 intnet

        VBoxManage modifyvm "$ADM_WSP_VM" --intnet2 "sonet_local_lan"

        # Port forwarding 3224 for ssh
        VBoxManage modifyvm "$ADM_WSP_VM" --natpf1 "guestssh,tcp,,3224,,22"

#.  запускаем VM

    .. code-block:: bash

        VBoxManage startvm "$ADM_WSP_VM"

#.  устанавливаем операционную систему, сразу настраиваем IP адрес на внутренней
    сети и устанавливаем openssh-server

#.  настраиваем авторизацию и прописываем ssh alias

    .. code-block:: bash

        ssh-copy-id -p 3224 -o IdentitiesOnly=yes -i ~/.ssh/id_rsa user@localhost

        cat >> ~/.ssh/config <<HERE
        Host "$ADM_WSP_VM"
            User user
            HostName localhost
            Port 3224
            IdentityFile ~/.ssh/id_rsa.pub
            IdentitiesOnly yes
        HERE

    Проверим подключение к VM:

    .. code-block:: bash

        ssh $ADM_WSP_VM

#.  Генерируем ssh ключи пользователя и отправляем их на сервер

    .. code-block:: bash

        ssh-keygen

        ssh-copy-id username@192.168.15.101

#.  установим дополнения VirtualBox для операционной системы

    .. code-block:: bash

        VBoxManage storageattach "$ADM_WSP_VM" --storagectl "IDE Controller" --port 0 \
            --device 0 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso

   на сервере выполним команды

    .. code-block:: bash

        sudo mount /dev/cdrom /media && sudo /media/VBoxLinuxAdditions.run

        sudo shutdown -h now

#.  сделаем на всякий случай snapshort

    .. code-block:: bash

        VBoxManage snapshot "$ADM_WSP_VM" take installer_finished

#.  приостановить работы VM и сохранив при этом ее состояние можно командой

    .. code-block:: bash

        VBoxManage controlvm "$ADM_WSP_VM" savestate

Рабочее место пользователя
~~~~~~~~~~~~~~~~~~~~~~~~~~

Для рабочей станции будем использовать `Linux Mint`_.

.. _`Linux Mint`: https://linuxmint.com/download.php

#.  создаем виртуальную машину:

    .. code-block:: bash

        USER_WSP_ISO="VirtualBox VMs/ISO/linuxmint-20-xfce-64bit.iso"
        USER_WSP_VM='sonet_local_worksp'
        USER_WSP_MEDIUM="$HOME/VirtualBox VMs/$USER_WSP_VM/$USER_WSP_VM.vdi"

        VBoxManage createvm --name "$USER_WSP_VM" --ostype "Ubuntu_64" --register

        VBoxManage modifyvm "$USER_WSP_VM" --description "sonet_local_worksp"

        VBoxManage createhd --filename "$USER_WSP_MEDIUM" --size 32768

        VBoxManage storagectl "$USER_WSP_VM" --name "SATA Controller" --add sata \
        --controller IntelAHCI

        VBoxManage storageattach "$USER_WSP_VM" --storagectl "SATA Controller" --port 0 \
        --device 0 --type hdd --medium "$USER_WSP_MEDIUM"

        VBoxManage storagectl "$USER_WSP_VM" --name "IDE Controller" --add ide

        VBoxManage storageattach "$USER_WSP_VM" --storagectl "IDE Controller" --port 0 \
        --device 0 --type dvddrive --medium "$USER_WSP_ISO"

        VBoxManage modifyvm "$USER_WSP_VM" --ioapic on

        VBoxManage modifyvm "$USER_WSP_VM" --boot1 dvd --boot2 disk --boot3 none --boot4 none

        VBoxManage modifyvm "$USER_WSP_VM" --memory 4096 --vram 128

        VBoxManage modifyvm "$USER_WSP_VM" --nic1 intnet

        VBoxManage modifyvm "$USER_WSP_VM" --intnet1 "sonet_local_lan"

#.  запускаем VM

    .. code-block:: bash

        VBoxManage startvm "$USER_WSP_VM"

#.  приостановить работы VM и сохранив при этом ее состояние можно командой

    .. code-block:: bash

        VBoxManage controlvm "$USER_WSP_VM" savestate
