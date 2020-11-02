<?php
    $config['imap_conn_options'] = array(
        'ssl' => array(
            'verify_peer'      => false,
            'verify_peer_name' => false,
            'cafile'           => '/etc/openssl/certs/ca.crt',
        ),
    );

    $config['smtp_conn_options'] = array(
        'ssl' => array(
            'verify_peer'      => false,
            'verify_peer_name' => false,
            'cafile'           => '/etc/openssl/certs/ca.crt',
        ),
    );
