terraform {
  # Keep backend configuration empty here and provide values at init time,
  # for example via shell environment variables expanded into -backend-config.
  backend "azurerm" {}
}

# Example:
# terraform init \
#   -backend-config="resource_group_name=$RESOURCE_GROUP_NAME" \
#   -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
#   -backend-config="container_name=$CONTAINER_NAME" \
#   -backend-config="key=terraform.tfstate"