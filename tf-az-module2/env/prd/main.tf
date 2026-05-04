locals {
  environment = "prd"
  project     = "tfmod2"

  config = {
    vm_size  = "Standard_B2s" # large
    cidr     = "10.10.0.0/16"
    location = "centralus"
  }

  name_prefix = "${local.project}-${local.environment}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    CostCenter  = "sandbox"
  }

  index_html = <<-HTML
    <!doctype html>
    <html>
      <head><title>${upper(local.environment)} — served from blob</title></head>
      <body style="font-family:system-ui;max-width:40em;margin:4em auto;">
        <h1>Hello from <strong>${upper(local.environment)}</strong></h1>
        <p>This page is served by nginx on the VM, but the file lives in
           an Azure blob container mounted via blobfuse2 at
           <code>/mnt/blobfuse</code>.</p>
        <p>Region: ${local.config.location}</p>
      </body>
    </html>
  HTML
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

module "storage" {
  source = "../../modules/storage"

  name_prefix         = "${local.project}${local.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  index_html_content  = local.index_html
  tags                = local.common_tags
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
    allow-http = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
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

  custom_data = base64encode(templatefile("${path.module}/../../templates/cloud-init.yaml.tpl", {
    storage_account_name = module.storage.storage_account_name
    storage_account_key  = module.storage.primary_access_key
    container_name       = module.storage.container_name
  }))
}

output "resource_group_name" {
  description = "Resource group containing this environment's resources."
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the per-env storage account (random suffix appended)."
  value       = module.storage.storage_account_name
}

output "blob_container_name" {
  description = "Name of the blob container backing nginx."
  value       = module.storage.container_name
}

output "vm_public_ip" {
  description = "Public IP of the VM."
  value       = module.vm.public_ip_address
}

output "web_url" {
  description = "HTTP URL for the nginx page served from the blob container."
  value       = "http://${module.vm.public_ip_address}/"
}

output "ssh_command" {
  description = "Ready-to-run SSH command using the generated private key."
  value       = "ssh -i ${local_file.ssh_private_key.filename} azureuser@${module.vm.public_ip_address}"
}
