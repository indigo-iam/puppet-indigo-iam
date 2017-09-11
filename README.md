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

Install Puppet 4 repository and package.
On Centos:
```console
$ sudo yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
$ sudo yum install -y redhat-lsb puppet
```

On Ubuntu:
```console
$ wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
$ sudo dpkg -i puppetlabs-release-pc1-xenial.deb
$ sudo apt-get install puppet-agent
```

## Usage
Install Puppet dependencies:

```console
$ sudo puppet module install puppetlabs-stdlib
$ sudo puppet module install maestrodev-wget
$ sudo puppet module install puppet-nginx
```

Write a manifest with essential parameters, following the examples provided in the `example` directory.

More configuration snippets can also be found [here](indigo_iam/README.md).

Then apply it:
```console
$ sudo puppet apply --modulepath=/etc/puppetlabs/code/environments/production/modules/:/mnt/workspace/puppet-indigo-iam/ /mnt/workspace/puppet-indigo-iam/indigo_iam/examples/iam_with_nginx.pp --debug
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
