<b>Medium:</b></n>

Create Medium with

```
hammer medium create --name 'Rocky8_xDVD_FTP' --path 'ftp://katello.sat.local/pub/Rocky_8dvd_x86_64/' --os-family 'Redhat' --location 'London' --organization 'Axcme'
```

<b>Partition tables:</b></n>

Now we create partition tables, we can use the default partition tables provided by Katello by let's try to make our own. 
We can list the partition tables with
```
hammar partition-table list
```

To create new 'Hardened Partition-table' which we will use, to get the --operatingsystems, use 'hammer os list'
first create hardened_ptables.txt
```
<%#
kind: ptable
name: Kickstart hardened 32GB
oses:
- CentOS
- Fedora
- RedHat
%>

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda --timeout=3
# Partition clearing information
clearpart --all --drives=sda
zerombr 

# Disk partitioning information
part /boot --fstype="xfs" --ondisk=sda --size=1024 --label=boot --fsoptions="rw,nodev,noexec,nosuid"

# 30GB physical volume
part pv.01  --fstype="lvmpv" --ondisk=sda --size=30720
volgroup vg_os pv.01

logvol /        --fstype="xfs"  --size=4096 --vgname=vg_os --name=lv_root
logvol /home    --fstype="xfs"  --size=512  --vgname=vg_os --name=lv_home --fsoptions="rw,nodev,nosuid"
logvol /tmp     --fstype="xfs"  --size=1024 --vgname=vg_os --name=lv_tmp  --fsoptions="rw,nodev,noexec,nosuid"
logvol /var     --fstype="xfs"  --size=6144 --vgname=vg_os --name=lv_var  --fsoptions="rw,nosuid"
logvol /var/log --fstype="xfs"  --size=512  --vgname=vg_os --name=lv_log  --fsoptions="rw,nodev,noexec,nosuid"
logvol swap     --fstype="swap" --size=2048 --vgname=vg_os --name=lv_swap --fsoptions="swap"
```
Now run the below command
```
hammer partition-table create --name 'Kickstart hardened 32GB' --os-family 'Redhat' --operatingsystems 'Rocky Linux 8.7' --file 'hardened_ptable.txt'
```
<b>Puppet Integration</b></n>
Run the following to integrate puppet with Foreman-Katello. If we already enabled these in step 1 we do't have to re run it.
```
foreman-installer --enable-foreman-plugin-puppet \
--enable-foreman-cli-puppet \
--foreman-proxy-puppet true \
--foreman-proxy-puppetca true \
--foreman-proxy-content-puppet true \
--enable-puppet \
--puppet-server true \
--puppet-server-foreman-ssl-ca /etc/pki/katello/puppet/puppet_client_ca.crt \
--puppet-server-foreman-ssl-cert /etc/pki/katello/puppet/puppet_client.crt \
--puppet-server-foreman-ssl-key /etc/pki/katello/puppet/puppet_client.key
```

<b>Puppet Environment:</b></n>
The 'hammer environment create or list' is depreciated.
Create a new environment, for Example: Production(already created by default), Dev, Testing, Lab etc. 
Do not forget --locations and --organizations flags, otherwise it will go to no-location and no-organization.
```
hammer puppet-environment create --name 'puppet-env-name-to-give' --locations 'XYZ' --organizations 'XYZ'
```

<b>Host Group</b></n>
We create the Host group:
```
hammer hostgroup create \
--name "rocky8_group" \
--description "Host group for Rocky 8 servers" \
--lifecycle-environment "stable" \
--content-view "Rocky8_CV" \
--content-source "katello.sat.local" \
--puppet-environment 'puppet-env-name-given'
--puppet-proxy-id 1 \
--puppet-ca-proxy-id 1 \
--domain "sat.local" \
--subnet "sat_Local" \
--architecture "x86_64" \
--operatingsystem "Rocky Linux 8.7" \
--medium "Rocky8_DVD_FTP" \
--partition-table "Kickstart hardened 32GB" \
--pxe-loader "PXELinux BIOS" \
--root-password "PASSWORD"
```

<b>Activation key:</b></n>
Activation key we created in previous steps are associated with this new Hostgroup
```
hammer hostgroup set-parameter --name 'kt_activation_keys' --value 'rocky8-main-key' --hostgroup 'rocky8_group'
```

<b>Vmware setup:</b></n>
Add new role e.g. satelliteadminrole in vCenter and assign privileges as per Foreman-Katello documentation. Now create new user e.g. satelliteadmin in vCenter and assign it the satelliteadminrole. Add new user at the bottom of Administration of vCenter and assign it new satelliteadminrole. Now go to vCenter->Inventory->rightclick'Datacenter'->Add Permission-> add satelliteadmin and assign it satelliteadminrole.

<b>Compute-Resource for Vmware:</b></n>
With above setup we can create a Vmware compute-resource
```
hammer compute-resource create --datacenter 'DomainForest' --description 'vSphere server at vcenter.kazmi.lab' --locations 'London' --organizations 'Axcme' --name 'kattelo_vcenter' --provider 'Vmware' --server '10.0.40.9' --user 'satelliteadmin@vsphere.local' --password 'PASSWORD' --set-console-password false
```
