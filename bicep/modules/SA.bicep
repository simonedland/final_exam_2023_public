// This template deploys a storage account with a container and enables http traffic
// Defines the parameters
param location string
param storageaccountname string
param containername string

// Creates a storage account with a container and enables http traffic
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageaccountname
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  // Enables http traffic
  properties: {
    supportsHttpsTrafficOnly: false
  }
  // Creates a container
  resource blob 'blobServices@2022-09-01' = {
    name: 'default'
    resource WEB_container 'containers@2022-09-01' = {
      name: containername
      properties: {
        immutableStorageWithVersioning: {
          enabled: false
        }
        publicAccess: 'None'
      }
    }
  }
}


// Outputs the storage account name and id
output storageAccountID string = storageAccount.id
output storageAccountName string = storageAccount.name
