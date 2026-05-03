resource "tls_private_key" "terrapriv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "terraprivkey" {
  filename        = "${path.module}/${local.name_prefix}-terrakey.pem"
  file_permission = "0600"
  content         = tls_private_key.terrapriv_key.private_key_pem
}

resource "azurerm_ssh_public_key" "terrakey" {
  name                = "${local.name_prefix}-ssh-key"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_key          = tls_private_key.terrapriv_key.public_key_openssh
  tags                = local.common_tags
}
