terraform {
  backend "azurerm" {
    resource_group_name  = "aztools"
    storage_account_name = "terraformtatesa"
    container_name       = "tf-az-dev"
    key                  = "terraform.tfstate"
  }
}
