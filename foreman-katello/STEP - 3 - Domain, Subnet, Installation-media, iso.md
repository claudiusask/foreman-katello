1. Create Domain if it's already not created; check with <b>hammer domain list</b>.
2. In order to create a subnet we need to know our TFTP ID. TFTP ID is actually our proxy ID. Check with <b>hammer proxy list</b>.
3. Create the subnet:
```
hammer subnet create \
--organizations "my_Organization" \
--locations "my_Location" \
--name "homelab_LAN" \
--network "10.0.0.0" \
--mask "255.255.255.0" \
--network-type "IPv4" \
--gateway "10.0.0.1" \
--dns-primary "10.0.0.xx" \
--dns-secondary "10.0.0.xx" \
--boot-mode "DHCP" \
--ipam "None" \
--domain-ids "1" \
--tftp-id "1"
```
4. Now we need to place the installation media some where our new provisioned VM's can access. We can do it through internet but to save the bandwidth we can create a location inside our forman-katello server or we can spin up a separate dedicated server for this which should be done in PROD environment.

Install vsftpd; WHY: so we have server our installation media over the local network:                        
```                        
dnf install vsftpd
systemctl enable vsftpd
firewall-cmd --permanent --add-service=ftp
firewall-cmd --reload
```                        
Edit /etc/vsftpd/vsftpd.conf and update the following parameters:
```            
anonymous_enable=YES
write_enable=NO
```                        
Now restart OR start the vsftpd
```                        
systemctl start vsftpd   OR    systemctl restart vsftpd
```
5. We create /etc/ftp/pub/CentOS_7_x86_64. We load the OS in CDrom of the Foreman-katello and copy it to /mnt folder:
```
mount /dev/cdrom /mnt
mkdir /var/ftp/pub/CentOS_7_x86_64
rsync -rv --progress /mnt/ /var/ftp/pub/CentOS_7_x86_64/
```
When the rsync completes we unmount the /mnt with:
```
umount /mnt
restorecon -Rv /var/ftp/pub/
```
