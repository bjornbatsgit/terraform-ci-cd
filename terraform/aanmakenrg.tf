# Configure the Microsoft Azure Provider infield ICT
#see main.tf

variable "resource_group_name" {
  type        = string
  default     = "RG-infra-wijzijnjong"
  description = " resource group wij zijn jong"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" { # Create virtual network
  name     = var.resource_group_name
  location = "west europe"

  tags = {
    Environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

