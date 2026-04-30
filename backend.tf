terraform {
  backend "azurerm" {}
}

# The backend settings (resource_group_name, storage_account_name,
# container_name, key) are provided via `-backend-config` flags or
# CLI/environmental overrides at `terraform init` time.