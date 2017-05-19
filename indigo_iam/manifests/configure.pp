class indigo_iam::configure (
  $active_profiles                = $indigo_iam::params::active_profiles,
  $java_opts                      = $indigo_iam::params::java_opts,
  $iam_base_url                   = $indigo_iam::params::iam_base_url,
  $iam_issuer                     = $indigo_iam::params::iam_issuer,
  $iam_use_forwarded_headers      = $indigo_iam::params::iam_use_forwarded_headers,
  $iam_key_store_location         = $indigo_iam::params::iam_key_store_location,
  $generate_keystore              = $indigo_iam::params::generate_keystore,
  $iam_organisation_name          = $indigo_iam::params::iam_organisation_name,
  $iam_db_host                    = $indigo_iam::params::iam_db_host,
  $iam_db_port                    = $indigo_iam::params::iam_db_port,
  $iam_db_schema                  = $indigo_iam::params::iam_db_schema,
  $iam_db_username                = $indigo_iam::params::iam_db_username,
  $iam_db_password                = $indigo_iam::params::iam_db_password,
  $iam_notification_disable       = $indigo_iam::params::iam_notification_disable,
  $iam_notification_from          = $indigo_iam::params::iam_notification_from,
  $iam_notification_task_delay    = $indigo_iam::params::iam_notification_task_delay,
  $iam_notification_admin_address = $indigo_iam::params::iam_notification_admin_address,
  $iam_mail_host                  = $indigo_iam::params::iam_mail_host,
  $iam_google_client_id           = $indigo_iam::params::iam_google_client_id,
  $iam_google_client_secret       = $indigo_iam::params::iam_google_client_secret,
  $iam_google_redirect_uris       = $indigo_iam::params::iam_google_redirect_uris,
  $iam_saml_entity_id             = $indigo_iam::params::iam_saml_entity_id,
  $iam_saml_keystore              = $indigo_iam::params::iam_saml_keystore,
  $iam_saml_keystore_password     = $indigo_iam::params::iam_saml_keystore_password,
  $iam_saml_key_id                = $indigo_iam::params::iam_saml_key_id,
  $iam_saml_key_password          = $indigo_iam::params::iam_saml_key_password,
  $iam_saml_idp_metadata          = $indigo_iam::params::iam_saml_idp_metadata,) inherits indigo_iam::params {
  #
  file { 'iam_env_file':
    ensure  => file,
    path    => $indigo_iam::params::environment_file,
    mode    => '0644',
    content => template('indigo_iam/iam-login-service.erb'),
    require => Package['iam-login-service'],;
  }

  $key_generator_source    = 'https://repo.cloud.cnaf.infn.it/repository/cnaf-releases/org/mitre/json-web-key-generator/0.4/json-web-key-generator-0.4-jar-with-dependencies.jar'
  $key_generator_jar_path  = '/usr/local/lib/json-web-key-generator.jar'
  $generated_keystore_path = '/var/cache/generated_keystore.jks'

  if $generate_keystore and $iam_key_store_location {
    wget::fetch { 'key_generator':
      source      => $key_generator_source,
      destination => $key_generator_jar_path,
    } ->
    exec { 'generate_keystore':
      command => "/usr/bin/java -jar ${key_generator_jar_path} -t RSA -s 1024 -S -i rsa1 | tail -n +2 > ${generated_keystore_path}",
      unless  => "/usr/bin/test -f ${generated_keystore_path}",
    }

    file { 'keystore':
      ensure  => file,
      path    => $iam_key_store_location,
      source  => $generated_keystore_path,
      owner   => $indigo_iam::params::iam_user,
      group   => $indigo_iam::params::iam_group,
      require => Exec['generate_keystore'],;
    }
  }
}
