terraform {
  # Default to a local backend for easier validation and testing.
  # To use the Azure RM backend, replace the block below with:
  # backend "azurerm" {
  #   resource_group_name  = "<rg>"
  #   storage_account_name = "<sa>"
  #   container_name       = "<container>"
  #   key                  = "terraform.tfstate"
  # }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate923197315"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Note: The repository uses an azurerm backend. If you want to
# store state in Azure Storage, run `terraform init -backend-config=...`
# or update this file with the azurerm backend configuration.