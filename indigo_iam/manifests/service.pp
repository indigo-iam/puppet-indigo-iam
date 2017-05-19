class indigo_iam::service (
  $service_manage = $indigo_iam::params::service_manage,
  $service_enable = $indigo_iam::params::service_enable,
  $service_ensure = $indigo_iam::params::service_ensure,) inherits indigo_iam::params {
  #
  if $service_manage {
    service { $indigo_iam::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['iam-login-service'],
      subscribe => File['iam_env_file'],;
    }
  }
}
