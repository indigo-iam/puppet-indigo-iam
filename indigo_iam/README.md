# Indigo IAM Puppet Module

### Install and start local IAM instance
```puppet
class { 'indigo_iam':
  iam_db_host                    => 'localhost',
  iam_db_schema                  => 'iam_login_service',
  iam_db_username                => 'iam-login-service',
  iam_db_password                => 'iam-login-service',
  active_profiles                => 'prod,registration',
}
```

### Automatically generate the keystore
```puppet
class { 'indigo-iam':
  ...
  generate_keystore              => true,
  iam_key_store_location         => '/var/lib/indigo/iam-login-service/keystore.jks',
  ...
}
```

### Activate and setup the notification service
```puppet
class { 'indigo-iam':
  ...
  iam_notification_disable       => false,
  iam_notification_from          => 'iam@iam-server.org',
  iam_notification_admin_address => 'admin@iam-server.org',
  iam_mail_host                  => 'smtp.example.org',
  ...
}
```

### Activate and setup Google external IDP
```puppet
class { 'indigo-iam':
  active_profiles                => 'prod,registration,google',
  ...
  iam_google_client_id           => 'google_client_id'
  iam_google_client_secret       => 'google_client_secret'
  iam_google_redirect_uris       => 'https://iam-server.example.org/openid_connect_login'
  ...
}
```

### Activate and setup SAML external IDP
```puppet
class { 'indigo-iam':
  active_profiles                => 'prod,registration,saml',
  ...
  iam_saml_entity_id             => 'https://iam-server.example.org'
  iam_saml_keystore              => '/var/lib/indigo/iam/iam-login-service/example.ks'
  iam_saml_keystore_password     => 'super-secret-password'
  iam_saml_key_id                => 'super-secret-id'
  iam_saml_key_password          => 'another-super-secret-password'
  iam_saml_idp_metadata          => '/var/lib/indigo/iam-login-service/example-metadata-sha256.xml'
  ...
}
```

### Deploy with reverse proxy
Configure IAM:
```puppet
$server   = 'iam-server.example.org'
$base_url = "https://${server}"

class { 'indigo_iam':
  iam_base_url                   => $base_url,
  iam_issuer                     => "${base_url}/",
  iam_db_host                    => 'localhost',
  iam_db_schema                  => 'iam_login_service',
  iam_db_username                => 'iam-user',
  iam_db_password                => 'iam-password',
  active_profiles                => 'prod,registration',
  ...
}
```
Install Nginx:
```puppet
class { 'nginx': }
```
Define an `upstream` host to point the local IAM instance:
```puppet
nginx::resource::upstream { 'iam_login_service': members => ['127.0.0.1:8080',], }
```
Define the virtual host that point the upstream server:
```puppet
nginx::resource::server { $server:
  ensure       => present,
  listen_port  => 443,
  proxy        => 'http://iam_login_service',
  ssl          => true,
  ssl_cert     => '/etc/pki/hostcert.pem',
  ssl_key      => '/etc/pki/hostkey.pem',
  ssl_redirect => true,
  http2        => 'on',
}
```
Finally, put everything together and apply the module.

The complete manifest can be found into the example folder.
