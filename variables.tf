variable "location" {
  type        = string
  description = "The Azure location to use for deployment"
}

variable "existingACRrgName" {
  type        = string
  description = "The Resource Group Name of the existing ACR"
}

variable "existingVnetRgName" {
  type        = string
  description = "The Resource Group Name of the existing Vnet"
}

variable "existingVnetName" {
  type        = string
  description = "Name of the existing Vnet"
}

variable "existingSubnetName" {
  type        = string
  description = "Name of the existing Vnet"
}

variable "userIdentityName" {
  type        = string
  description = "User Assigned managed Identity Name"
}

variable "agent_name_prefix" {
  type        = string
  description = "Name prefix"
}

variable "docker_image" {
  type        = string
  description = ""
}

variable "azure_devops_org_name" {
  type        = string
  description = ""
}

variable "server" {
  type        = string
  description = ""
}

variable "agent_pool_name" {
  type        = string
  description = ""
}

variable "image_tag" {
  type        = string
  description = ""
}

variable "PAT_TOKEN" {
  type        = string
  description = ""
}
