locals {
  ubuntu = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  nodes = merge(
    { (var.ansible_name) = { size = var.vm_size_ansible, public_ip = false } },
    { (var.master_name)  = { size = var.vm_size_master,  public_ip = false } },
    { for w in var.worker_names : w => { size = var.vm_size_worker, public_ip = (w == "client1" || w == "client2") } }
  )
}

# Resource Group(s)
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.rtags
}

# Networking
resource "azurerm_virtual_network" "vnet" {
  name                = var.vn_name
  address_space       = var.vn_address
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.rtags
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.rtags

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "sg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IPs
resource "azurerm_public_ip" "pip" {
  for_each            = { for k, v in local.nodes : k => v if v.public_ip }
  name                = "pip-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.rtags
}

resource "azurerm_network_interface" "nic" {
  for_each            = local.nodes
  name                = "nic-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public_ip ? azurerm_public_ip.pip[each.key].id : null
  }

  tags = var.rtags
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = local.nodes
  name                  = each.key
  computer_name         = each.key
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = each.value.size  # The size will be set based on the updated variable
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
  disable_password_authentication = true

  os_disk {
    name                 = "osdisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.ubuntu.publisher
    offer     = local.ubuntu.offer
    sku       = local.ubuntu.sku
    version   = local.ubuntu.version
  }

  tags = merge(var.rtags, { role = each.key })
}
