terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.51.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}


provider "azurerm" {
  features {
  }
  # client_id = "63a460b4-6d84-4f54-b4ee-a3de013fe278"
  # client_secret = "lXg8Q~~GUiIzZEVuPCdyjwLX2IefLsZII_YpebUJ"
  # tenant_id = "b1147ebc-723a-4081-b981-f0ae8a56561e"
  # subscription_id = "f27e0956-3775-4a34-9ff9-5a1ff3149dd9"
}
