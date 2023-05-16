terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "lynx-order-tracker-dev-plan"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.resource_group.name
  sku {
    tier = "Standard"
    size = "S1"
  }
  tags = {
    Owner   = "Timo Lehtonen"
    DueDate = "2023-05-31"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "lynx-order-tracker-dev"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    always_on = true
  }

  tags = {
    Owner   = "Timo Lehtonen"
    DueDate = "2023-05-31"
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = "lynx-order-tracker-dev-rg"
  location = "northeurope"
  tags = {
    Owner   = "Timo Lehtonen"
    DueDate = "2023-05-31"
  }
}
