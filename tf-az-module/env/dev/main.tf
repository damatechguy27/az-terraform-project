locals {
  environment = "dev"
  project     = "tfmod"

  config = {
    vm_size  = "Standard_B1ms" # small
    cidr     = "10.30.0.0/16"
    location = "eastus"
  }

  name_prefix = "${local.project}-${local.environment}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    CostCenter  = "sandbox"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = local.config.location
  tags     = local.common_tags
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  filename        = "${path.module}/${local.name_prefix}-terrakey.pem"
  file_permission = "0600"
  content         = tls_private_key.ssh.private_key_pem
}

module "vnet" {
  source = "../../modules/vnet"

  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [local.config.cidr]
  tags                = local.common_tags
}

module "subnet" {
  source = "../../modules/subnet"

  name                 = "${local.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [cidrsubnet(local.config.cidr, 8, 1)]
}

module "nsg" {
  source = "../../modules/nsg"

  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  security_rules = {
    allow-ssh = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "0.0.0.0/0"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = module.subnet.id
  network_security_group_id = module.nsg.id
}

module "vm" {
  source = "../../modules/vm"

  name                 = "${local.name_prefix}-vm-01"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  subnet_id            = module.subnet.id
  vm_size              = local.config.vm_size
  admin_ssh_public_key = tls_private_key.ssh.public_key_openssh
  tags                 = local.common_tags
}

output "resource_group_name" {
  description = "Resource group containing this environment's resources."
  value       = azurerm_resource_group.main.name
}

output "vm_public_ip" {
  description = "Public IP of the VM."
  value       = module.vm.public_ip_address
}

output "ssh_command" {
  description = "Ready-to-run SSH command using the generated private key."
  value       = "ssh -i ${local_file.ssh_private_key.filename} azureuser@${module.vm.public_ip_address}"
}
