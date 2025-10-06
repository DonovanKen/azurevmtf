# Azure Service Principal credentials
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

# Resource Group name
variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

# Optional extra resource groups (name -> location)
variable "resource_group_names" {
  description = "Optional extra RGs (name -> location)"
  type = map(object({
    location = string
  }))
  default = {}
}

# Azure region for resource deployment
variable "location" {
  description = "Azure region"
  type        = string
  default     = "canadacentral"
}

# Tags for resources
variable "rtags" {
  description = "Tags"
  type        = map(string)
  default     = { project = "k8s-lab", owner = "terraform" }
}

# Network Configuration
variable "vn_name" {
  description = "Virtual Network name"
  type        = string
}

# VNet CIDRs (list of CIDR blocks)
variable "vn_address" {
  description = "VNet CIDRs"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Example default value
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

# Subnet CIDR block
variable "subnet_address" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"  # Example default value
}

# NSG inbound rules
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

# SSH & VM sizing
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
  description = "VM size for ansible host (2 GiB)"
  type        = string
  default     = "Standard_B1ms"
}

# VM names
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
  default     = ["client1", "client2"]  # Example worker names
}
