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

<b>Host Group</b></n>
The 'hammer environment create or list' is depreciated so we create the Host group:
```

```
