class { 'indigo_iam':
  iam_base_url                   => 'https://cloud-vm194.cloud.cnaf.infn.it',
  iam_issuer                     => 'https://cloud-vm194.cloud.cnaf.infn.it/',
  iam_db_host                    => 'localhost',
  iam_db_schema                  => 'iam_login_service',
  iam_db_username                => 'iam',
  iam_db_password                => 'iam_login_service',
  active_profiles                => 'prod,registration',
  iam_notification_disable       => false,
  iam_notification_from          => 'user@localhost',
  iam_notification_admin_address => 'user@localhost',
  iam_mail_host                  => 'localhost',
  generate_keystore              => true,
  iam_key_store_location         => '/var/lib/indigo/iam-login-service/keystore.jks',
  iam_repo_branch                => 'nightly',
  iam_version                    => 'latest',
} ~>
class { 'nginx': }

nginx::resource::upstream { 'iam_login_service': members => ['127.0.0.1:8080',], }

nginx::resource::server { 'cloud-vm194.cloud.cnaf.infn.it':
  ensure       => present,
  listen_port  => 443,
  proxy        => 'http://iam_login_service',
  ssl          => true,
  ssl_cert     => '/etc/pki/hostcert.pem',
  ssl_key      => '/etc/pki/hostkey.pem',
  ssl_redirect => true,
  spdy         => 'on',
  http2        => 'on',
}

nginx::resource::server { 'default':
  ensure               => present,
  listen_options       => 'default_server',
  listen_port          => 80,
  ssl                  => false,
  ssl_redirect         => true,
  use_default_location => false,
}
