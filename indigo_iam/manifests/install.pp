class indigo_iam::install (
  $iam_version     = $indigo_iam::params::iam_version,
  $iam_repo_branch = $indigo_iam::params::iam_repo_branch,) inherits indigo_iam::params {
  #

  $iam_pkg_version = $iam_version

  if !($iam_version in ['present', 'latest', 'absent']) {
    $iam_pkg_version = $::operatingsystem ? {
      /CentOS/ => "${iam_version}.el7.centos",
      /Ubuntu/ => $iam_version,
      default  => undef,
    } }

  $repo_refresh_command       = $::operatingsystem ? {
    /CentOS/ => 'yum clean all && yum makecache',
    /Ubuntu/ => 'apt-get clean && apt-get update',
    default  => undef,
  }

  $allow_unauth_pkgs_filepath = $::operatingsystem ? {
    /CentOS/ => '/tmp/fake-99auth',
    /Ubuntu/ => '/etc/apt/apt.conf.d/99auth',
    default  => undef,
  }

  $allow_unauth_pkgs_content  = $::operatingsystem ? {
    /CentOS/ => '',
    /Ubuntu/ => 'APT::Get::AllowUnauthenticated yes;',
    default  => undef,
  }

  file {
    'iam_repofile':
      ensure  => file,
      path    => $repo_filepath,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template("indigo_iam/${repo_filename}.erb"),
      require => File['unauth_pkg_file'],;

    'unauth_pkg_file':
      ensure  => file,
      path    => $allow_unauth_pkgs_filepath,
      owner   => root,
      group   => root,
      content => $allow_unauth_pkgs_content,
      mode    => '0644',;
  }

  exec { 'repo_refresh':
    command     => $repo_refresh_command,
    path        => ['/usr/bin'],
    subscribe   => File['iam_repofile'],
    refreshonly => true,
  }

  package { 'iam-login-service':
    ensure  => $iam_pkg_version,
    require => File['iam_repofile'],
  }
}
