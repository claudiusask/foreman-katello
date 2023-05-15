Ansible must be enabled (go to STEP 1)

Now we need to do the following in foreman-katello server
```
sudo dnf makecache --refresh
```
```
sudo dnf -y install rhel-system-roles
```
<b>Import Ansible roles:</b>
We need to import the ansible roles in GUI with Configure -> Ansible -> Roles. On the top right import the Ansible Roles
