<?php
    //Разрешить поиск и автодополнение из массива AD
    $rcmail_config['autocomplete_addressbooks'] = array('sql','AD');

    $config['ldap_public'] = array(
    //Имя массива, в котором выполняется поиск
        'AD' =>array (
            'name' => 'LDAP', //Отображаемое имя в интерфейсе WEBMail Roundcube
            'hosts' => array('{{ conf['ldap_hostname'] }}'), //IP адрес или ДНС имя
            'sizelimit' => 600,
            'port' => 389,
            'use_tls' => false,
            'user_specific' => false,
            'base_dn' => '{{ openldap['ldap_base_dn'] }}', //Где выполнять поиск
            'bind_dn' => 'cn={{ openldap['ldap_readonly_user_username'] }},{{ openldap['ldap_base_dn'] }}', //Авторизация на контроллере домена
            'bind_pass' => '{{ openldap['ldap_readonly_user_password'] }}', //Авторизация на контроллере домена
            'writable' => false,
            'ldap_version' => 3,
            'search_fields' => array(
            'mail',
            'cn',
            'sn',
            ),
            'name_field' => 'displayName',
            'email_field' => 'mail',
            'surname_field' => 'sn',
            'firstname_field' => 'givenName',
            //Можно добавить немного дополнительной информации в адресной книге
            // 'organization_field'     => 'company',
            // 'jobtitle_field'    => 'title',
            // 'department_field'   => 'department',
            //Порядок сортировки
            'sort' => 'sn',
            'scope' => 'sub', //Выполнять поиск по всему каталогу LDAP // search mode: sub|base|list
            'filter' => '(&(objectClass=person)(mailenable=OK)(mail=*))',
            //'filter' => '(&(mail=*)(|(&(objectcategory=person)(!(objectClass=computer)))(objectClass=group)))',
            'global_search' => true,
            'fuzzy_search' => true
        ),
    );

    // ----------------------------------
    // LDAP
    // ----------------------------------
    // Type of LDAP cache. Supported values: 'db', 'apc' and 'memcache'.
    $config['ldap_cache'] = 'db';
    // Lifetime of LDAP cache. Possible units: s, m, h, d, w
    $config['ldap_cache_ttl'] = '10m';
