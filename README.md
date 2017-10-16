# indigo_iam-mw-devel

## Requirements
Install and configure a database server. Then create a schema for IAM with a dedicated username and password.
Take note of the database hostname, schema, username and password: they will used later in Puppet manifest.

This module require Puppet version >= 4.10.

Platform supported:
- CentOS 7
- Ubuntu 16.04

## Preliminary operations
Relax SELinux, setting `permissive` in `/etc/sysconfig/selinux` and rebooting the machine.

Install Puppet repository and package.
On Centos:
```console
$ sudo yum install -y https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
$ sudo yum install -y redhat-lsb puppet-agent
```

On Ubuntu:
```console
$ wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
$ sudo dpkg -i puppet5-release-xenial.deb
$ sudo apt update
$ sudo apt-get install puppet-agent
```

## Usage
Install Indigo IAM Puppet module:

```console
$ wget https://github.com/indigo-iam/puppet-indigo-iam/releases/download/v0.1.0/cnaf-indigo_iam-0.1.0.tar.gz
$ puppet module install cnaf-indigo_iam-0.1.0.tar.gz
```

Write a manifest with setting IAM parameters.
For example, the following manifest sets up IAM Login Service and a reverse proxy to serve IAM on SSL:

```puppet
$server   = 'cloud-vm194.cloud.cnaf.infn.it'
$base_url = "https://${server}"

class { 'indigo_iam':
  iam_base_url                   => $base_url,
  iam_issuer                     => "${base_url}/",
  iam_db_host                    => 'localhost',
  iam_db_schema                  => 'iam_login_service',
  iam_db_username                => 'iam',
  iam_db_password                => 'super_secret_password',
  active_profiles                => 'prod,registration',
  iam_notification_disable       => false,
  iam_notification_from          => 'user@localhost',
  iam_notification_admin_address => 'user@localhost',
  iam_mail_host                  => 'localhost',
  generate_keystore              => true,
  iam_key_store_location         => '/var/lib/indigo/iam-login-service/keystore.jks',
  iam_repo_branch                => 'stable',
} ~>
class { 'nginx': }

nginx::resource::upstream { 'iam_login_service': members => ['127.0.0.1:8080',], }

nginx::resource::server { $server:
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
```

More configuration snippets can also be found [here](indigo_iam/README.md).

Then apply it:
```console
$ sudo puppet apply manifest.pp --debug
```

## Deployment Tips
In headless servers, running `haveged` daemon is recommended to generate more entropy.
Before run IAM Login service, check the available entropy with:

```console
$ cat /proc/sys/kernel/random/entropy_avail
```

If the obtained value is less than 1000, then `haveged` daemon is mandatory.

On CentOS only, install EPEL repository:
```console
$ sudo yum install -y epel-release
```
 Install Haveged:
```console
$ sudo yum install -y haveged
```
or in Ubuntu:
```console
$ sudo apt-get install haveged
```

Enable and run it:
```console
$ sudo systemctl enable haveged
$ sudo systemctl start haveged
```
