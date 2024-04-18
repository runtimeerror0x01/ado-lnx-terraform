# resource "azurerm_resource_group" "rg" {                # create new network rg optional.
#   name     = var.NewRgName                             # using this rg for new useridentity
#   location = var.location
# }

# Optional, if creating new vnet and subnet with deligation.

# resource "azurerm_virtual_network" "vnet" {
#   name                = "vnet-aci-devops"
#   address_space       = ["10.1.0.0/16"]
#   location            = "uksouth"
#   resource_group_name = azurerm_resource_group.vnet-rg.name
# }

# resource "azurerm_subnet" "aci-subnet" {
#   name                 = "aci-subnet"
#   resource_group_name  = azurerm_resource_group.vnet-rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.1.1.0/24"]

#   delegation {
#     name = "acidelegation"

#     service_delegation {
#       name    = "Microsoft.ContainerInstance/containerGroups"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#     }
#   }
# }

# data "azurerm_virtual_network" "vnet" {
#   name                = var.existingVnetName
# }

data "azurerm_subnet" "aci-subnet" {
  name                 = var.existingSubnetName    # Name of the existing subnet
  virtual_network_name = var.existingVnetName      # Name of the existing VNet
  resource_group_name  = var.existingVnetRgName   # Resource group name where the existing VNet is located
}

data "azurerm_resource_group" "acr-rg" {                 # rg where the ACR resides.
  name                 = var.existingACRrgName                       
}

resource "azurerm_user_assigned_identity" "myIdentity" {
name                   = var.userIdentityName
resource_group_name    = var.existingVnetRgName
location               = var.location

}
 
resource "azurerm_role_assignment" "aci" {
  scope                = data.azurerm_resource_group.acr-rg.id                      # scoped to acr rg.
  role_definition_name = "acrpull"                                                  # image pull permission.
  principal_id         = azurerm_user_assigned_identity.myIdentity.principal_id     # pid from the identity resource above.
  depends_on = [
    azurerm_user_assigned_identity.myIdentity
  ]
}

module "aci-devops-agent" {
  source                = "./modules/"
  resource_group_name   = "rg-aci-devops"
  location              = var.location
  create_resource_group = true
  enable_vnet_integration  = true
  vnet_resource_group_name = data.azurerm_subnet.aci-subnet.resource_group_name
  vnet_name                = data.azurerm_subnet.aci-subnet.virtual_network_name
  subnet_name              = data.azurerm_subnet.aci-subnet.name

  linux_agents_configuration = {
    agent_name_prefix = var.agent_name_prefix
    count             = 1
    docker_image      = var.docker_image
    docker_tag        = var.image_tag
    agent_pool_name   = var.agent_pool_name
    cpu               = 1
    memory            = 2
    user_assigned_identity_ids   = [ azurerm_user_assigned_identity.myIdentity.id]
    use_system_assigned_identity = false    
  }

    image_registry_credential = {
      server = var.server
      identity = azurerm_user_assigned_identity.myIdentity.id
    }

  azure_devops_org_name              = var.azure_devops_org_name
  azure_devops_personal_access_token = var.PAT_TOKEN

  depends_on                         = [azurerm_user_assigned_identity.myIdentity]
}