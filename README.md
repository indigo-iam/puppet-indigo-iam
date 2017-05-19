# indigo_iam-mw-devel

## Usage 
Install Puppet dependency:

```console
$ sudo puppet module install puppetlabs-stdlib
```

Write a manifest with essential parameters, following the example provided in the `example` directory.
Then apply it:
```console
$ sudo puppet apply --modulepath=/etc/puppet/modules/:/mnt/workspace/indigo-iam/ /mnt/workspace/indigo-iam/indigo_iam/examples/init.pp --debug
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
$ sudo yum install epel-release
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
