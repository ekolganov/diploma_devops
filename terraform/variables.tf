variable "my_name" {
  default = "EKolganov"
}

variable "location" {
  default = "eastus"
}

variable "vm_sku" {
  default = "Standard_DS2_v2"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
