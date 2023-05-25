// Deploy a static website to Azure Storage using Bicep
// Parameters
param location string = 'norwayeast'
var storageaccountname = 'simonsbicepdeploymentsa'
var containername = '$web'
var rgname = 'rg-bicep-prod-norwayeast-001'
var idname = 'id-bicep-prod-norwayeast-001'
var poolSize = 4

// Refers to the secrets.bicep file
module secrets 'modules/secrets.bicep' = {
  name: 'secrets'
}
// Defines the output variables from the secrets.bicep file
var subnet_id = secrets.outputs.subnet_id
var mypublicip = secrets.outputs.my_public_ip

 //Create a resource group
module myRG 'modules/rg.bicep' = {
  scope: subscription()
  name: rgname
  params: {
    name: rgname
    location: location
  }
}

// Create a user assigned identity
module identity 'modules/ID.bicep' = {
  scope: resourceGroup(myRG.name)
  dependsOn: [myRG]
  name: idname
  params: {
    identityName: idname
    location: location
  }
}

// Create a storage account
module storageAccount 'modules/SA.bicep' = [for i in range(0, poolSize): {
  scope: resourceGroup(myRG.name)
  dependsOn: [myRG]
  name: '${storageaccountname}${i}'
  params: {
    location: location
    storageaccountname: '${storageaccountname}${i}'
    containername: containername
  }
}]


// Set up network security rules
module settings 'modules/settings.bicep' = [for i in range(0, poolSize): {
  scope: resourceGroup(myRG.name)
  dependsOn: [storageAccount]
  name: 'settings${i}'
  params: {
    location: location
    subnet_id: subnet_id
    mypublicip: mypublicip
    rgName: myRG.outputs.rgname
    idName: identity.outputs.idname
    storageAccountName: storageAccount[i].outputs.storageAccountName
    storageAccountID: storageAccount[i].outputs.storageAccountID
    file1: loadTextContent('web_data/index.html')
    filename1: 'index.html'
    file2: loadTextContent('web_data/bicep-logo.svg')
    filename2: 'bicep-logo.svg'
  }
}]
