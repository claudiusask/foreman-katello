So Instead of creating Medium and Partition Tables, it's better to use templates on VMware. We can create our own template(image) with Hashigroup Packer. After creating this template on VMware we can setup this for Cloud-init as per Foreman documentation.

# Setup Cloud-init for Image on VMware

Convert the template and run the following commands or add these commands in the packer's post installation scripts so we don't have to do it manually.


These instructions are for Enterprise Linux or Fedora, follow similar steps for other Linux distributions.
Procedure

On the virtual machine that you use to create the image, install cloud-init, open-vm-tools, and perl:

```
dnf install cloud-init open-vm-tools perl
```

Disable network configuration by cloud-init:

```
# cat << EOM > /etc/cloud/cloud.cfg.d/01_network.cfg
network:
  config: disabled
EOM
```

Configure cloud-init to fetch data from Foreman:

```
# cat << EOM > /etc/cloud/cloud.cfg.d/10_datasource.cfg
datasource_list: [NoCloud]
datasource:
  NoCloud:
seedfrom: https://foreman.example.com/userdata/
EOM
```

Configure modules to use in cloud-init:

```
# cat << EOM > /etc/cloud/cloud.cfg
cloud_init_modules:
 - bootcmd

cloud_config_modules:
 - runcmd

cloud_final_modules:
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - phone-home

system_info:
  distro: rhel
  paths:
cloud_dir: /var/lib/cloud
templates_dir: /etc/cloud/templates
  ssh_svcname: sshd
EOM
```

Enable the CA certificates for the image:

```
# update-ca-trust enable
```

Download the katello-server-ca.crt file from Foreman server:

```
# wget -O /etc/pki/ca-trust/source/anchors/cloud-init-ca.crt http://foreman.example.com/pub/katello-server-ca.crt
```

To update the record of certificates, enter the following command:

```
# update-ca-trust extract
```

Use the following commands to clean the image:

```
# systemctl stop rsyslog
# service auditd stop  *** systemctl stop auditd doesn't work
# *** Doesn't work *** No need to do this package-cleanup --oldkernels --count=1
# dnf clean all
```

Use the following commands to reduce logspace, remove old logs, and truncate logs:

```
# logrotate -f /etc/logrotate.conf
# rm -f /var/log/*-???????? /var/log/*.gz
# rm -f /var/log/dmesg.old
# rm -rf /var/log/anaconda
# cat /dev/null > /var/log/audit/audit.log
# cat /dev/null > /var/log/wtmp
# cat /dev/null > /var/log/lastlog
# cat /dev/null > /var/log/grubby
```

Remove udev hardware rules:

```
# rm -f /etc/udev/rules.d/70*
```

Remove the ifcfg scripts related to existing network configurations:

```
# rm -f /etc/sysconfig/network-scripts/ifcfg-ens*
# rm -f /etc/sysconfig/network-scripts/ifcfg-eth*
```

Remove the SSH host keys:

```
# rm -f /etc/ssh/SSH_keys
```

Remove root user’s SSH history:

```
# rm -rf ~root/.ssh/known_hosts
```

Remove root user’s shell history:

```
# rm -f ~root/.bash_history
# unset HISTFILE
```

On the Foreman-Katello server we have to run this command to configure a setting to recognize host ip addresses as per our ip range:

```
foreman-installer --foreman-trusted-proxies 127.0.0.1/8 --foreman-trusted-proxies ::1 --foreman-trusted-proxies 192.0.2.0/24
```

<i>
*** OLD way START***

<b>Medium:</b>

Create Medium with

```
hammer medium create --name 'Rocky8_xDVD_FTP' --path 'ftp://katello.sat.local/pub/Rocky_8dvd_x86_64/' \
--os-family 'Redhat' --location 'London' --organization 'Axcme'
```

<b>Partition tables:</b>

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
*** OLD way END***
</i>
  
<b>Puppet Integration</b>

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

<b>Puppet Environment:</b>

The 'hammer environment create or list' is depreciated.
Create a new environment, for Example: Production(already created by default), Dev, Testing, Lab etc. 
Do not forget --locations and --organizations flags, otherwise it will go to no-location and no-organization.
```
hammer puppet-environment create --name 'puppet-env-name-to-give' --locations 'XYZ' --organizations 'XYZ'
```
# Create or Configure OS:
We need to configure or create new OS for image provisioning using the template(image) we setup in previous setps.

```
hammer os create --name RockyOSD8 --major 8 --minor 7 --family 'Redhat' --password-hash 'SHA256' --architectures x86_64
```

Now we associate the 'Cloud-init default' and 'UserData open-vm-tools' provisioning template with our OS. 
To find the id of templates, run:

```
hammer template list
```

To Associate the template with OS run: Also re run again if needed to add more templates:

```
hammer template add-operatingsystem --id 30 --operatingsystem-id 5
```
Now for the next setup I have not found anything with 'hammer os cli' so i will use GUI.
  HOST --> Provisioning Setup --> Operating Systems --> SELECT-new-os-we-create-in-previous-steps --> Templates and select the approriate templates for Cloud-init and UserData. Remove all others.

<b>Host Group</b>

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
--root-password "PASSWORD"
```

<b>Activation key:</b>

Activation key we created in previous steps are associated with this new Hostgroup
```
hammer hostgroup set-parameter --name 'kt_activation_keys' --value 'rocky8-main-key' --hostgroup 'rocky8_group'
```

<b>Vmware setup:</b>

Add new role e.g. satelliteadminrole in vCenter and assign privileges as per Foreman-Katello documentation. Now create new user e.g. satelliteadmin in vCenter and assign it the satelliteadminrole. Add new user at the bottom of Administration of vCenter and assign it new satelliteadminrole. Now go to vCenter->Inventory->rightclick'Datacenter'->Add Permission-> add satelliteadmin and assign it satelliteadminrole.

<b>Compute-Resource for Vmware:</b>

With above setup we can create a Vmware compute-resource
```
hammer compute-resource create --datacenter 'DomainForest' \
--description 'vSphere server at vcenter.kazmi.lab' \
--locations 'London' --organizations 'Axcme' \
--name 'kattelo_vcenter' --provider 'Vmware' \
--server '10.0.40.9' \
--user 'satelliteadmin@vsphere.local' \
--password 'satelliteadminPASSWORD' \
--set-console-password false
```

<b>Compute Profile:</b>

The JSON format is working better so we can create the profiles in CLI with it.
First we create profile with

```
hammer compute-profile create --name 'XYZ_Profile'
```

Now we can set VMware details to a compute profile, we will use this profile in next step.

```
hammer compute-profile values create \
--compute-profile-id 6 --compute-resource-id 1 \
'--compute-attributes={"cpus":1,"corespersocket":2,"memory_mb":2048,"firmware":"efi","resource_pool":"Resources","cluster":"Forest Cluster","guest_id":"centos8_64Guest","path":"/Datacenters/DomainForest/vm/ForemanLab","hardware_version":"Default","memoryHotAddEnabled":0,"cpuHotAddEnabled":0,"add_cdrom":0,"boot_order":["disk","network"],"scsi_controllers":[{"type":"ParaVirtualSCSIController","key":1000},{"type":"ParaVirtualSCSIController","key":1001}]}' \
'--interface={"compute_type":"VirtualVmxnet3","compute_network":"network-28"}' \
'--volume={"size_gb":"20G","datastore":"DISKNAME","name":"katelloDisk","thin":"true"}'
```
<b>Create Host:</b>

The host can be create indiviually or we can run a script which I did and created bunch of host. 

<b>The plan to create hosts with scripts:</b>

So what I did was created 4 files:
  1. hosts.csv
  2. multi_host_deploy.sh
  3. update_host_mac.sh
  4. macadd_scripts.ps1
  
 <b> 1. Hosts.csv: </b> So in this what i added were HOSTNAME,00:00:00:00,ip-address. First we add hostname without fQDN, so just the hostname after the comma we can add MAC_Address and after another comma we add ip-address. We can add other hosts on each new line.
 
 <b> 2. Multi_host_deploy.sh Script: </b> In this we added the following script:
 
```
#!/bin/bash

while IFS=, read -r host_name mac_add
do
hammer host create --compute-profile-id 7 \
--compute-resource "katello_vcenter" \
--enabled true \
--hostgroup "rocky8_group" \
--image "rocky_8_xTemp" \
--location "London" \
--managed true \
--name "${host_name}" \
--organization "XYZ" \
--provision-method image
done < hosts.csv
pwsh ./macadd_script.ps1
```
                
What this is doing is using the hosts.csv from step 1 and looping through all the systems HOSTNAME and mac_address and creating them one by one, remember the mac_address at this moment will be given out automatically by VMware. In the last step we run the powershell-powercli script macadd_script.ps1 which will change the mac_add of all the hosts as per our policy in our Datacenter. But the mac_address in the Foreman-Katello is still the old one which as auto-given by VMware, even if we explicitly give the mac-address in the above script.

<b> 3. Update_mac_host.sh: </b> This is the script used to update the hosts mac_address in Foreman-Katello.

```
#!/bin/bash

while IFS=, read -r host_name mac_add
do
mac_get=$(hammer host info --name ${host_name}.sat.local --fields Network/mac | awk '{ print $2; }' | awk '!/^$/')

if [[ "${mac_add}" != "$mac_get" ]]
then
        hammer host update --name ${host_name}.sat.local --mac ${mac_add}
        echo "Mac address for ${host_name} has been update"
else
        echo "Mac address is same, no need to update for ${host_name}"
fi
done < hosts.csv

```

<b> 4. macadd_script.ps1: </b> We have to install powershell on Katello server. Then we have to install powercli in powershell and then we can run this script which will update the mac_address on the Vmware vm's. All these mac_address update scripts will auto find, compare and if needed will update the mac_addresses.

```
Connect-VIServer -Server 'vcenter.xyz.com' -Protocol https -User 'administrator@vsphere.local' -Password '123456789-or-whatever'

$hosts_get = Import-Csv -Path "hosts.csv" -Header 'Host', 'Mac'

foreach ($item in $hosts_get) {
        # Access the key-value pairs using dot notation
        $get_mac = Get-VM "$($item.Host).sat.local" | Get-NetworkAdapter | select -ExpandProperty MacAddress
        if($get_mac -ne $item.Mac){
                Get-VM "$($item.Host).sat.local" | Get-NetworkAdapter | Set-NetworkAdapter -MacAddress $item.Mac -Confirm:$false
                Get-VM "$($item.Host).sat.local" | Get-NetworkAdapter | Set-NetworkAdapter -startconnected:$true -Confirm:$false
        }
}
disconnect-viserver -confirm:$false

```

<i> Check vm nic in vSphere if they are connected after changing the mac_address. </i>


# Autosign Puppet Signing Requests -- Only GUI

The Puppet signing requests for all servers will be listed under:

Infrastructure > Smart Proxies > Puppet CA > Certificates   and add *.xyz.com
