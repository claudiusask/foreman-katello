vsphere_server   = "vcenter.kazmi.lab"
vsphere_user     = "Administrator@vsphere.local"
#vsphere_password =
datacenter       = "LabDatacenter"
cluster          = "LabCluster"
datastore        = "iscsistore"
network_name     = "Data"
builder_ipv4     = "10.0.0.50"
ssh_username     = "root"
#ssh_password     = 
# EXPORT "vsphere_password" & "ssh_password" like below example:
# Also don't forget to put an extra space before the word "export" in below example, so the password won't be saved in bash history.
#-------------LINUX---EXAMPLE------------------#
# export PKR_VAR_vsphere_password="YOUR-TOP-SECRET-PASSWORD"
# export PKR_VAR_ssh_password="YOUR-TOP-SECRET-PASSWORD"
#-------------Windows---Powershell---Example---#
# $env:PKR_VAR_vsphere_password="YOUR-TOP-SECRET-PASSWORD"
# $env:PKR_VAR_ssh_password="YOUR-TOP-SECRET-PASSWORD"