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
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vnetName": {
            "type": "string",
            "metadata": {
                "description": "Name of the VNET"
            }
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2020-05-01",
            "name": "[parameters('vnetName')]",
            "location": "[resourceGroup().location]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "10.0.0.0/16"
                    ]
                }
            }
        }
    ],
    "outputs": {
      "exampleOutput": {
        "type": "string",
        "value": "someoutput"
      }
    }
}
TEMPLATE

  // NOTE: whilst we show an inline template here, we recommend
  // sourcing this from a file for readability/editor support
}

output arm_example_output {
  value = jsondecode(azurerm_resource_group_template_deployment.aztemplate.output_content).exampleOutput.value
}
    

