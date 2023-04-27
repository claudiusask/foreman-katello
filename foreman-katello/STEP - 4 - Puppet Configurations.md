## Now we need to setup Puppet.

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
MOD_DIR=/etc/puppetlabs/code/environments/katellopuppetlab/modules

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
