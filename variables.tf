variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  default     = "rg-lab"
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource naming (eg. lab, prod)"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "eastus"
}

variable "vnets" {
  description = "Map of virtual networks to create. Key = vnet name, value.address_space = list of CIDR blocks and subnets"
  type = map(object({
    address_space = list(string)
    subnets       = map(string)
  }))
  default = {
    qa-dep = {
      address_space = ["10.10.0.0/16"]
      subnets = {
        public  = "10.10.0.0/24"
        private = "10.10.1.0/24"
      }
    }
    hr-dep = {
      address_space = ["10.20.0.0/16"]
      subnets = {
        private = "10.20.0.0/24"
      }
    }
    rnd-dep = {
      address_space = ["10.30.0.0/16"]
      subnets = {
        private = "10.30.0.0/24"
      }
    }
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (relative to repo root)"
  type        = string
  default     = "keys/lab-key.pub"
}

variable "vm_size" {
  description = "VM SKU for linux instances"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "vms" {
  description = "Map of VMs to create. key = vm name. fields: vnet, subnet, public"
  type = map(object({
    vnet   = string
    subnet = string
    public = bool
  }))
  default = {
    bastion = { vnet = "qa-dep", subnet = "public", public = true }
    linux1  = { vnet = "qa-dep", subnet = "private", public = false }
    linux2  = { vnet = "hr-dep", subnet = "private", public = false }
    linux3  = { vnet = "rnd-dep", subnet = "private", public = false }
  }
}

variable "repo_name" {
  description = "Optional repository name to include as a tag. If empty, derived from module path."
  type        = string
  default     = ""
}
variable "storage_account_name" {
  description = "Name of the storage account used for Terraform state"
  type        = string
  default     = ""
}

variable "storage_account_resource_group" {
  description = "Resource group containing the tfstate storage account"
  type        = string
  default     = ""
}

variable "git_repo" {
  description = "Repository URL used for tagging the storage account"
  type        = string
  default     = ""
}

variable "git_branch" {
  description = "Git branch used for tagging the storage account"
  type        = string
  default     = ""
}

variable "git_commit" {
  description = "Git commit SHA used for tagging the storage account"
  type        = string
  default     = ""
}

variable "git_commit_date" {
  description = "Git commit date/time (ISO 8601) used for tagging the storage account"
  type        = string
  default     = ""
}

variable "checkpoint_sp_object_id" {
  description = "Object ID of the Check Point service principal in your tenant (preferred input)."
  type        = string
  default     = ""

  validation {
    condition     = var.checkpoint_sp_object_id == "" || can(regex("^[0-9a-fA-F-]{36}$", var.checkpoint_sp_object_id))
    error_message = "checkpoint_sp_object_id must be empty or a valid GUID."
  }
}

variable "isv_sp_object_id" {
  description = "Legacy alias for checkpoint_sp_object_id. Keep empty unless you need backward compatibility."
  type        = string
  default     = ""

  validation {
    condition     = var.isv_sp_object_id == "" || can(regex("^[0-9a-fA-F-]{36}$", var.isv_sp_object_id))
    error_message = "isv_sp_object_id must be empty or a valid GUID."
  }
}

variable "assignable_scopes" {
  description = "Subscription or resource group scopes where Check Point is allowed to use this role. This does not grant access by itself; role assignments do."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for s in var.assignable_scopes : can(regex("^/subscriptions/[0-9a-fA-F-]{36}(/resourceGroups/[^/]+)?$", s))
    ])
    error_message = "Each assignable scope must match /subscriptions/<subscription-guid> or /subscriptions/<subscription-guid>/resourceGroups/<resource-group-name>."
  }
}

variable "role_assignment_scopes" {
  description = "Optional explicit scopes where role assignments are created. If empty, assignable_scopes is used. Supports subscription, resource group, or VNet resource scopes."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for s in var.role_assignment_scopes : can(regex("^/subscriptions/[0-9a-fA-F-]{36}(/resourceGroups/[^/]+(/providers/Microsoft\\.Network/virtualNetworks/[^/]+)?)?$", s))
    ])
    error_message = "Each role assignment scope must match a subscription, resource group, or VNet resource ID."
  }
}