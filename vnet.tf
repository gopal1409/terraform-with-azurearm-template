locals {
  vnet_name = "arm-vnet"
}
resource "azurerm_resource_group_template_deployment" "aztemplate" {
  name                = "${local.resource_name_prefix}-arm-vnet"
  #location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "vnetName" = {
      value = local.vnet_name
    }
  })
  template_content = <<TEMPLATE
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vnetName": {
            
            "type": "String",
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2022-05-01",
            "name": "[parameters('vnetName')]",
            "location": "[resourceGroup().location]",
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), 'default')]"
            ],
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "10.2.0.0/16"
                    ]
                },
                "subnets": [
                    {
                        "name": "default",
                        "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworks_ansible_vnet_name'), 'default')]",
                        "properties": {
                            "addressPrefix": "10.2.0.0/24",
                            "delegations": [],
                            "privateEndpointNetworkPolicies": "Disabled",
                            "privateLinkServiceNetworkPolicies": "Enabled"
                        },
                        "type": "Microsoft.Network/virtualNetworks/subnets"
                    }
                ],
                "virtualNetworkPeerings": [],
                "enableDdosProtection": false
            }
        },
        {
            "type": "Microsoft.Network/virtualNetworks/subnets",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('virtualNetworks_ansible_vnet_name'), '/default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualNetworks', parameters('virtualNetworks_ansible_vnet_name'))]"
            ],
            "properties": {
                "addressPrefix": "10.2.0.0/24",
                "delegations": [],
                "privateEndpointNetworkPolicies": "Disabled",
                "privateLinkServiceNetworkPolicies": "Enabled"
            }
        }
    ]
}
TEMPLATE

  // NOTE: whilst we show an inline template here, we recommend
  // sourcing this from a file for readability/editor support
}

/*output arm_example_output {
  value = jsondecode(azurerm_resource_group_template_deployment.aztemplate.output_content).exampleOutput.value
}*/
    

