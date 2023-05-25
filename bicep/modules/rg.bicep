// Create a resource group in a subscription scope
targetScope = 'subscription'

// Define the parameters for the deployment
param location string
param name string

// Define the resourse group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: name
  location: location
}

// Define the output
output rgname string = rg.name
