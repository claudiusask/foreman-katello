variable "vsphere_server" {
  type    = string
  default = "vcsa.kazmi.lab"
}

variable "vsphere_user" {
  type    = string
  default = "Administrator@vsphere.local"
}

variable "vsphere_password" {
  type    = string
}

variable "datacenter" {
  type    = string
  default = "LabDatacenter"
}

variable "cluster" {
  type    = string
  default = "Lab Cluster"
}

variable "datastore" {
  type    = string
  default = "iSCSI-Datastore"
}

variable "network_name" {
  type    = string
  default = "vData"
}

variable "ssh_password" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "builder_ipv4"{
  type = string
  description = "This variable is used to manually assign the IPv4 address to serve the HTTP directory. Use this to override Packer if it utilising the wrong interface."
}