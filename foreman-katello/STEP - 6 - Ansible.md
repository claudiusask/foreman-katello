Ansible must be enabled (go to STEP 1)

Now we need to do the following in foreman-katello server
```
sudo dnf makecache --refresh
```
```
sudo dnf -y install rhel-system-roles
```
Now we install hammer cli for ansible

```
dnf install rubygem-hammer_cli_foreman_ansible
```
<b>Import Ansible roles:</b>
We need to import the ansible roles in GUI with Configure -> Ansible -> Roles. On the top right import the Ansible Roles
OR we can use the cli.
```
hammer ansible roles fetch --proxy-id 1
```
With the above command we can list all the roles and later we can use the below command to import the roles.
```
hammer ansible roles import --proxy-id 1 --role-names 'Name-Of-Role'
```
