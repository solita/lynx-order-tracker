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

# PostgreSQL db
resource "azurerm_postgresql_server" "postgresql_server" {
  name                = "lynx-order-tracker-dev-db"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku_name            = "B_Gen5_1"
  storage_mb          = 5120
  version             = "11"
  ssl_enforcement_enabled = true

  administrator_login          = "lynx-order-tracker-dev"
  administrator_login_password = random_password.postgresql_password.result

  tags = {
    environment = "dev"
  }
}

resource "azurerm_postgresql_database" "postgresql_database" {
  name                = "lynx-order-tracker-dev-db"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "random_password" "postgresql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# PostgreSQL firewall rule
resource "azurerm_postgresql_firewall_rule" "postgresql_firewall_rule" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  start_ip_address    = "95.175.96.152"
  end_ip_address      = "95.175.96.152"
}
