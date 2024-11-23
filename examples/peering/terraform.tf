terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "remote"
  subscription_id = data.azurerm_subscription.current.subscription_id // current subscription to succeed tests
  features {}
}

data "azurerm_subscription" "current" {}
