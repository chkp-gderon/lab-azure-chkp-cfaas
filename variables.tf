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
    bastion = { vnet = "qa-dep", subnet = "public",  public = true }
    linux1  = { vnet = "qa-dep", subnet = "private", public = false }
    linux2  = { vnet = "hr-dep", subnet = "private",  public = false }
    linux3  = { vnet = "rnd-dep", subnet = "private", public = false }
  }
}

variable "repo_name" {
  description = "Optional repository name to include as a tag. If empty, derived from module path."
  type        = string
  default     = ""
}