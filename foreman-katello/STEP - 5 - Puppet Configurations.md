## Now we need to setup Puppet.

It's better to change the /tmp directory for puppetserver (Foreman-Katello is my puppetserver or proxyServer)
Create a directory in new location

```
mkdir -m 1777 /opt/puppetlabs/tmp
```
Change the temp directory in /etc/sysconfig/puppetserver and add <i>-Djava.io.tmpdir=/opt/puppetlabs/tmp</i> at the end of the below line.

```
JAVA_ARGS="-Xms2G -Xmx2G ......... -Djava.io.tmpdir=/opt/puppetlabs/tmp"
```
<b>Tmp directory service </b>
Start and enable the tmp.mount service
```
systemctl start tmp.mount
```
now enable it
```
systemctl enable tmp.mount
```
ALSO don't forget the DNS, if the host-client can't see hostname of katello server or the katello server can't ping the host-client hostname, the remote execution doesn't work.

<b>File Structure</b>
Let us go ahead and create a folder structure:

```
mkdir -p /etc/puppetlabs/code/environments/homelab/{manifests,modules}
```
Create the main manifest and set appropriate group permissions:

```
touch /etc/puppetlabs/code/environments/homelab/manifests/site.pp
```
```
chgrp puppet /etc/puppetlabs/code/environments/homelab/manifests/site.pp
```
```
chmod 0640 /etc/puppetlabs/code/environments/homelab/manifests/site.pp
```

We can now go ahead and start installing Puppet modules.

<b>Puppet Modules</b>

Now this was time consuming becasue I had to adjust module verions and their depencencies. We can use r10k from puppet but
I didn't go that route because it was more time consuming than the setup I went with.
So below is the script I used to install modules from puppet Forge.

```
#!/bin/bash

# Specify the directory to download modules to
MOD_DIR=/etc/puppetlabs/code/environments/homelab/modules

# Specify the modules you want to install
MODULES=(
  puppet-keepalived
  puppet-selinux
  saz-limits
  thias-sysctl
  puppet-openldap
  simp-sssd
  puppetlabs-apache
  hunner-wordpress
  puppetlabs-mysql
  puppet-corosync
  derdanne-nfs
  puppet-snmp
  graylog-graylog
  puppet-elasticsearch
  puppet-mongodb
  puppetlabs-haproxy
  puppetlabs-firewall

)
# If the below 2 lines give the issue, we can use puppet-corosync to install old version
# of stdlib.
puppet module install --modulepath $MOD_DIR puppet-corosync
puppet module install --modulepath $MOD_DIR puppet-systemd --version 3.10.0
puppet module install --modulepath $MOD_DIR puppetlabs-stdlib --version 7.1.0

# Loop through each module and download it
for module in "${MODULES[@]}"
do
  puppet module install --modulepath $MOD_DIR $module
done

# Print a message indicating that installation is complete
echo "Module installation complete!"

# Add puppet-zabbix separately
```

Take a look at this script. The Zabbix is missing from this because Zabbix relies on old dependencies. Look at the output below and see at the end where it says zabbix(???).  

```
/etc/puppetlabs/code/environments/homelab/modules
├── derdanne-nfs (v2.1.11)
├── graylog-graylog (v1.0.0)
├── hunner-wordpress (v1.0.0)
├── n-axcme_firewall (v0.1.0)
├── puppet-archive (v6.1.2)
├── puppet-augeasproviders_core (v3.2.0)
├── puppet-augeasproviders_shellvar (v5.0.0)
├── puppet-corosync (v8.2.0)
├── puppet-elastic_stack (v8.0.2)
├── puppet-elasticsearch (v8.1.0)
├── puppet-epel (v4.1.0)
├── puppet-keepalived (v3.6.0)
├── puppet-mongodb (v4.2.0)
├── puppet-openldap (v6.1.0)
├── puppet-selinux (v3.4.1)
├── puppet-snmp (v6.0.0)
├── puppet-systemd (v3.10.0)
├── puppet-yum (v6.2.0)
├── puppet-zypprepo (v4.0.1)
├── puppetlabs-apache (v10.0.0)
├── puppetlabs-apt (v8.5.0)
├── puppetlabs-augeas_core (v1.3.0)
├── puppetlabs-concat (v7.4.0)
├── puppetlabs-firewall (v5.0.0)
├── puppetlabs-haproxy (v7.0.0)
├── puppetlabs-inifile (v5.4.1)
├── puppetlabs-java (v8.2.0)
├── puppetlabs-java_ks (v4.4.2)
├── puppetlabs-mysql (v14.0.0)
├── puppetlabs-stdlib (v7.1.0)
├── puppetlabs-transition (v1.0.0)
├── saz-limits (v3.1.0)
├── simp-simpkv (v0.8.0)
├── simp-simplib (v4.10.4)
├── simp-sssd (v7.4.2)
├── thias-sysctl (v1.0.7)
└── zabbix (???)
/etc/puppetlabs/code/environments/common (no modules installed)
/etc/puppetlabs/code/modules (no modules installed)
/opt/puppetlabs/puppet/modules (no modules installed)
/usr/share/puppet/modules (no modules installed)
```

I installed zabbix seperate from this script but with the below command:

```
puppet module install puppet-zabbix --target-dir=/etc/puppetlabs/code/environments/homelab/modules/zabbix
```

<b>Install PDK from puppet to create our own modules</b>

```
sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-8.noarch.rpm
```

```
dnf install pdk
```

Now cd into /etc/puppetlabs/code/environments/homelab/modules/ to create new module

```
pdk new module xyz_firewall
```

This above command will create the boilerplates for our own module creation.

Now we cd into xyz_firewall/manifests and we will find files init.pp, pre.pp and post.pp the pre.pp and post.pp are create by myself.

Ok so start editing these files as below:

<b>init.pp</b>

```
# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include axcme_firewall
class xyz_firewall ($firewall_data = false) {
  include xyz_firewall::pre
  include xyz_firewall::post

  resources { "firewall":
    purge => true
  }

  Firewall {
    before  => Class['xyz_firewall::post'],
    require => Class['xyz_firewall::pre'],
  }

  if $firewall_data != false {
    create_resources('firewall', $firewall_data)
  }
}

```

<b>pre.pp</b>

```
# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include xyz_firewall::pre
class xyz_firewall::pre {
Firewall {
    require => undef,
  }
  firewall { '000 drop all IPv6':
    proto    => 'all',
    action   => 'drop',
    provider => 'ip6tables',
  }->
  firewall { '001 allow all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  firewall { '003 allow all ICMP':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '004 allow related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  firewall { '005 allow SSH':
    proto  => 'tcp',
    source => '192.168.0.0/24',
    state  => [ "NEW" ],
    dport  => '22',
    action => 'accept',
  }
}

```

<b>post.pp</b>

```
class xyz_firewall::post {
   firewall {'999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}
```

Restore the Selinux context with:

```
restorecon -Rv /etc/puppetlabs/code/environments/homelab/
```

puppet environments and classes can be updated using foreman-rake:

```
foreman-rake puppet:import:puppet_classes
```
```
foreman-rake puppet:import:environments_only
```

If the above doesn't work in GUI we can go to Configure > Puppet Environments > Import environments from katello.homelab.local
This will import the modules into the homelab environment. Do the same for Puppet classes:
Configure > Puppet Classes > Import environments from katello.homelab.local

<b>Configure xyz_firewall Smart Class Parameter</b>
Navigate to Configure > Puppet Classes in GUI and find the xyz_firewall class. Edit the Smart class parameter and set the $firewall_data key param type to yaml and select Override in Default behavior. This will allow to pass in any additional firewall rules via yaml.

<b>Serving Files from a Custom Location</b>
Create new file in /etc/puppetlabs/puppet/fileserver.conf and edit it with the below content:

```
[homelab_files]
  path /etc/puppetlabs/code/environments/homelab/homelab_files
  allow *
```

Create a custom directory to server the files from puppet:

```
mkdir /etc/puppetlabs/code/environments/homelab/homelab_files
```

<b>Create TLS certificate for homelab</b>

```
# cd /etc/puppetlabs/code/environments/homelab/homelab_files
# DOMAIN=sat
# openssl genrsa -out "$DOMAIN".key 4096 && chmod 0600 "$DOMAIN".key
# openssl req -new -sha256 -key "$DOMAIN".key -out "$DOMAIN".csr
# openssl x509 -req -days 1825 -sha256 -in "$DOMAIN".csr \
  -signkey "$DOMAIN".key -out "$DOMAIN".crt
# openssl pkcs8 -topk8 -inform pem -in "$DOMAIN".key \
-outform pem -nocrypt -out "$DOMAIN".pem
```
Verify the certificates

```
openssl x509 -in sat.crt -text -noout|grep CN
```

<b>Defining the Main Manifest</b>
We need to edit /etc/puppetlabs/code/environments/homelab/manifests/site.pp as below:

```
##
## File: site.pp
## Author: Tomas at www.lisenet.com
## Edited by: ME
## Date: March 2018
## Edit date: April 2023
##
## This manifest defines services in the following order:
##
## 1. OpenSSH server config
## 2. Packages and services
## 3. Sudo and User config
## 4. SELinux config
## 5. Sysctl config
## 6. System security limits
##

##
## The name default (without quotes) is a special value for node names.
## If no node statement matching a given node can be found, the default 
## node will be used.
##

node 'default' {}

##
## Note: the axcme_firewall class should not be assigned here,
## but rather added to Katello Host Groups. This is to allow us
## to utilise Smart Class Parameters and add additional rules
## per host by using Katello WebUI. 
##

#################################################
## OpenSSH server configuration for the env
#################################################

## Rocky 8 OpenSSH server configuration
if ($facts['os']['family'] == 'RedHat') and ($facts['os']['release']['major'] == '8') {
  class { 'ssh::server':
    validate_sshd_file => true,
    options => {
      'Port'                   => '22',
      'ListenAddress'          => '0.0.0.0',
      'Protocol'               => '2',
      'SyslogFacility'         => 'AUTHPRIV',
      'LogLevel'               => 'INFO',
      'MaxAuthTries'           => '3',
      'MaxSessions'            => '5',
      'AllowUsers'             => ['root','user1'],
      'PermitRootLogin'        => 'without-password',
      'HostKey'                => ['/etc/ssh/ssh_host_ed25519_key', '/etc/ssh/ssh_host_rsa_key'],
      'PasswordAuthentication' => 'yes',
      'PermitEmptyPasswords'   => 'no',
      'PubkeyAuthentication'   => 'yes',
      'AuthorizedKeysFile'     => '.ssh/authorized_keys',
      'KerberosAuthentication' => 'no',
      'GSSAPIAuthentication'   => 'yes',
      'GSSAPICleanupCredentials' => 'yes',
      'ChallengeResponseAuthentication' => 'no',
      'HostbasedAuthentication' => 'no',
      'IgnoreUserKnownHosts'   => 'yes',
      'PermitUserEnvironment'  => 'no',
      'UsePrivilegeSeparation' => 'yes',
      'StrictModes'            => 'yes',
      'UsePAM'                 => 'yes',

      'LoginGraceTime'         => '60',
      'TCPKeepAlive'           => 'yes',
      'AllowAgentForwarding'   => 'no',
      'AllowTcpForwarding'     => 'no',
      'PermitTunnel'           => 'no',
      'X11Forwarding'          => 'no',
      'Compression'            => 'delayed',
      'UseDNS'                 => 'no',
      'Banner'                 => 'none',
      'PrintMotd'              => 'no',
      'PrintLastLog'           => 'yes',
      'Subsystem'              => 'sftp /usr/libexec/openssh/sftp-server',

      'Ciphers'                => 'chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr',
      'MACs'                   => 'hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com',
      'KexAlgorithms'          => 'curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group16-sha512,diffie-hellman-group14-sha256',
      'HostKeyAlgorithms'      => 'ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ssh-rsa-cert-v01@openssh.com,ssh-dss-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com',
    },
  }
}

#################################################
## Packages/services configuration for the env
#################################################
  ## We want these packages installed on all servers
  $packages_to_install = [
    'bzip2',
    'deltarpm',
    'dos2unix',
    'gzip',
    'htop',
    'iotop',
    'lsof',
    'mailx',
    'net-tools',
    'nmap-ncat',
    'postfix',
    'rsync',
    'screen',
    'tmux',
    'strace',
    'sudo',
    'sysstat',
    'unzip',
    'vim' ,
    'wget',
    'xz',
    'yum-cron',
    'yum-utils',
    'zip',
  ]
  package { $packages_to_install: ensure => 'installed' }

  ## We do not want these packages on servers
  $packages_to_purge = [
    'aic94xx-firmware',
    'alsa-firmware',
    'alsa-utils',
    'ivtv-firmware',
    'iw',
    'iwl1000-firmware',
    'iwl100-firmware',
    'iwl105-firmware',
    'iwl135-firmware',
    'iwl2000-firmware',
    'iwl2030-firmware',
    'iwl3160-firmware',
    'iwl3945-firmware',
    'iwl4965-firmware',
    'iwl5000-firmware',
    'iwl5150-firmware',
    'iwl6000-firmware',
    'iwl6000g2a-firmware',
    'iwl6000g2b-firmware',
    'iwl6050-firmware',
    'iwl7260-firmware',
    'iwl7265-firmware',
    'wireless-tools',
    'wpa_supplicant',
  ]
  package { $packages_to_purge: ensure => 'purged' }

  ##
  ## Manage some specific services below
  ##
  service { 'kdump': enable => false, }
  service { 'puppet': enable => true, }
  service { 'sysstat': enable => false, }
  service { 'yum-cron': enable => true, }

  ##
  ## Configure NTP
  ##
  class { 'ntp':
    servers  => ['katello.sat.local'],
    restrict => ['127.0.0.1'],
  }

  ##
  ## Configure Postfix via postconf
  ## Note how we configure smtp_fallback_relay 
  ##
  service { 'postfix': enable => true, ensure => "running", }
  exec { "configure_postfix":
    path     => '/usr/bin:/usr/sbin:/bin:/sbin',
    provider => shell,
    command  => "postconf -e 'inet_interfaces = localhost' \
                'relayhost = admin1.sat.local' \
                'smtp_fallback_relay = admin2.sat.local' \
                'smtpd_banner = $hostname ESMTP'",
    unless   => "grep ^smtp_fallback_relay /etc/postfix/main.cf",
    notify   => Exec['restart_postfix']
  }
  exec { 'restart_postfix':
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    provider    => shell,
    ## Using service rather than systemctl to make it portable
    command     => "service postfix restart",
    refreshonly => true,
  }

  if ($facts['os']['release']['major'] == '8') {
    ## Disable firewalld and install iptables-services
    package { 'iptables-services': ensure => 'installed' }
    service { 'firewalld': enable => "mask", ensure => "stopped", }
    service { 'iptables': enable => true, ensure => "running", }
    service { 'ip6tables': enable => true, ensure => "running", }
    service { 'tuned': enable => true, }
    package { 'chrony': ensure => 'purged' }
  }

  ## Wildcard *.sat.local TLS certificate for homelab
  file { '/etc/pki/tls/certs/sat.crt':
    ensure => 'file',
    source => 'puppet:///homelab_files/sat.crt',
    path => '/etc/pki/tls/certs/sat.crt',
    owner => '0',
    group => '0',
    mode  => '0644',
  }
  file { '/etc/pki/tls/private/sat.key':
    ensure => 'file',
    source => 'puppet:///homelab_files/sat.key',
    path => '/etc/pki/tls/private/sat.key',
    owner => '0',
    group => '0',
    mode  => '0640',
  }

#################################################
## Sudo and Users configuration for the env
#################################################

class { 'sudo':
  purge               => true,
  config_file_replace => true,
}
sudo::conf { 'wheel_group':
  content  => "%wheel ALL=(ALL) ALL",
}

## These are necessary for passwordless SSH
file { '/root/.ssh':
  ensure  => 'directory',
  owner   => '0',
  group   => '0',
  mode    => '0700',
}

file { '/root/.ssh/authorized_keys':
  # Require the parent directory to be created beforehand.
  require => File['/root/.ssh/'],
  ensure  => 'file',
  owner   => '0',
  group   => '0',
  mode    => '0600',
  content => "# Managed by Puppet\n\n\nssh-rsa key-string\n",
}

#################################################
## SELinux configuration for the environment
#################################################

class { selinux:
  mode => 'enforcing',
  type => 'targeted',
}

#################################################
## Sysctl configuration for the environment
#################################################

sysctl { 'fs.suid_dumpable': value => '0' }
sysctl { 'kernel.dmesg_restrict': value => '1' }
sysctl { 'kernel.kptr_restrict': value => '2' }
sysctl { 'kernel.randomize_va_space': value => '2' }
sysctl { 'kernel.sysrq': value => '0' }
sysctl { 'net.ipv4.tcp_syncookies': value => '1' }
sysctl { 'net.ipv4.tcp_timestamps': value => '1' }
sysctl { 'net.ipv4.conf.default.accept_source_route': value => '0' }
sysctl { 'net.ipv4.conf.all.accept_redirects': value => '0' }
sysctl { 'net.ipv4.conf.default.accept_redirects': value => '0' }
sysctl { 'net.ipv4.conf.all.send_redirects': value => '0' }
sysctl { 'net.ipv4.conf.default.send_redirects': value => '0' }
sysctl { 'net.ipv4.conf.all.secure_redirects': value => '0' }
sysctl { 'net.ipv4.conf.default.secure_redirects': value => '0' }
sysctl { 'net.ipv4.conf.all.rp_filter': value => '1' }
sysctl { 'net.ipv4.conf.default.rp_filter': value => '1' }
sysctl { 'net.ipv4.conf.all.log_martians': value => '1' }
sysctl { 'net.ipv4.conf.default.log_martians': value => '1' }
sysctl { 'net.ipv6.conf.lo.disable_ipv6': value => '0' }
sysctl { 'net.ipv6.conf.all.disable_ipv6': value => '0' }
sysctl { 'net.ipv6.conf.default.disable_ipv6': value => '0' }
sysctl { 'net.ipv6.conf.all.accept_redirects': value => '0' }
sysctl { 'net.ipv6.conf.default.accept_redirects': value => '0' }
sysctl { 'vm.swappiness': value => '40' }

#################################################
## Security limits configuration for the env
#################################################

limits::limits { '*/core':   hard => 0; }
limits::limits { '*/fsize':  both => 67108864; }
limits::limits { '*/locks':  both => 65535; }
limits::limits { '*/nofile': both => 65535; }
limits::limits { '*/nproc':  both => 16384; }
limits::limits { '*/stack':  both => 32768; }
limits::limits { 'root/locks':  both => 65535; }
limits::limits { 'root/nofile': both => 65535; }
limits::limits { 'root/nproc':  both => 16384; }
limits::limits { 'root/stack':  both => 32768; }

## Module does not manage the file /etc/security/limits.conf
## We might as well warn people from editing it.
file { '/etc/security/limits.conf':
  ensure  => 'file',
  owner   => '0',
  group   => '0',
  mode    => '0644',
  content => "# Managed by Puppet\n\n",
}

```
