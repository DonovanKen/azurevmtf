
variable "client_id" {
  description = "Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}


variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}


# variable "resource_group_names" {
#   description = "Optional extra RGs (name -> location)"
#   type = map(object({
#     location = string
#   }))
#   default = {}
# }


variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US" 
}


variable "rtags" {
  description = "Tags"
  type        = map(string)
  default     = { project = "k8s-lab", owner = "terraform" }
}


variable "vn_name" {
  description = "Virtual Network name"
  type        = string
}


variable "vn_address" {
  description = "VNet CIDRs"
  type        = list(string)
  default     = ["10.0.0.0/16"] 
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}


variable "subnet_address" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24" 
}


variable "nsg_rules" {
  description = "NSG inbound rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}


variable "admin_username" {
  description = "Linux admin username"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Your public SSH key (~/.ssh/id_rsa.pub)"
  type        = string
}

variable "vm_size_master" {
  description = "VM size for master (4 GiB)"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_size_worker" {
  description = "VM size for workers (2 GiB)"
  type        = string
  default     = "Standard_B1ms"  
}

variable "vm_size_ansible" {
  description = "VM size for ansible host (4 GiB)"
  type        = string
  default     = "Standard_B2s"
}


variable "ansible_name" {
  description = "Ansible VM name"
  type        = string
  default     = "ansimachine"
}

variable "master_name" {
  description = "K8s master VM name"
  type        = string
  default     = "master"
}

variable "worker_names" {
  description = "K8s worker names"
  type        = list(string)
  default     = ["client1", "client2"]  
}
