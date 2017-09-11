class indigo_iam::params {
  # General
  $iam_version     = 'latest'
  $iam_repo_branch = 'stable' # Values: nightly, beta, stable

  $iam_user        = 'iam'
  $iam_group       = 'iam'

  case $::operatingsystem {
    'CentOS' : {
      $environment_file = '/etc/sysconfig/iam-login-service'
      $repo_filename    = 'indigo-iam.repo'
      $repo_filepath    = "/etc/yum.repos.d/${repo_filename}"
    }
    'Ubuntu' : {
      $environment_file = '/etc/default/iam-login-service'
      $repo_filename    = 'indigo-iam.list'
      $repo_filepath    = "/etc/apt/sources.list.d/${repo_filename}"
    }
    default  : {
      fail('Unsupported OS')
    }
  }

  $generate_keystore              = false

  $service_manage                 = true
  $service_name                   = 'iam-login-service'
  $service_enable                 = true
  $service_ensure                 = 'running'

  # Conf variables
  $active_profiles                = 'prod,registration'
  $java_opts                      = '-Xms512m -Xmx1024m'
  $iam_base_url                   = 'https://iam.example.org'
  $iam_issuer                     = "${iam_base_url}/"
  $iam_use_forwarded_headers      = true
  $iam_key_store_location         = undef # '/var/lib/indigo/iam-login-service/keystore.jks'
  $iam_organisation_name          = 'example-org'

  # DB connection
  $iam_db_host                    = 'localhost'
  $iam_db_port                    = '3306'
  $iam_db_schema                  = 'iam-login-service'
  $iam_db_username                = 'iam'
  $iam_db_password                = 'iam-login-service'

  # Notification settings
  $iam_notification_disable       = true
  $iam_notification_from          = undef
  $iam_notification_task_delay    = 5000
  $iam_notification_admin_address = undef
  $iam_mail_host                  = 'localhost'

  # Google settings
  $iam_google_client_id           = undef
  $iam_google_client_secret       = undef
  $iam_google_redirect_uris       = "${iam_base_url}/openid_connect_login"

  # SAML settings
  $iam_saml_entity_id             = undef
  $iam_saml_keystore              = undef # '/var/lib/indigo/iam/iam-login-service/example.ks'
  $iam_saml_keystore_password     = undef
  $iam_saml_key_id                = undef
  $iam_saml_key_password          = undef
  $iam_saml_idp_metadata          = undef # '/var/lib/indigo/iam-login-service/example-metadata-sha256.xml'
}
