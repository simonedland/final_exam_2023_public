// Variables and parameters
var subId = subscription().subscriptionId
param rgName string
param idName string
param location string
param subnet_id string
param mypublicip string
param storageAccountName string
param storageAccountID string
param file1 string
param filename1 string
param file2 string
param filename2 string

// Deploys security rules for storage account
resource deploymentScript1 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymentScript${storageAccountName}'
  location: location
  kind: 'AzureCLI'
  // Uses managed identity to run script
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subId}/resourcegroups/${rgName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${idName}': {}
    }
  }
  // Script to run
  properties: {
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccountName
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: listKeys(storageAccountID, '2020-08-01-preview').keys[0].value
      }
      {
        name: 'CONTENT1'
        value: file1
      }
      {
        name: 'CONTENT2'
        value: file2
      }
    ] 
    cleanupPreference: 'Always'
    retentionInterval: 'PT1H'
    azCliVersion: '2.40.0'
    scriptContent: 'echo "$CONTENT2" > ${filename2} && az storage blob upload -f ${filename2} -c "$"web --overwrite true && echo "$CONTENT1" > ${filename1} && az storage blob upload -f ${filename1} -c "$"web --overwrite true && az storage blob service-properties update --account-name ${storageAccountName} --static-website --404-document index.html --index-document index.html && az storage account network-rule add --resource-group "${rgName}" --account-name "${storageAccountName}" --subnet ${subnet_id} && az storage account network-rule add --resource-group "${rgName}" --account-name "${storageAccountName}" --ip-address "${mypublicip}" && az storage account update --resource-group "${rgName}" --name "${storageAccountName}"  --default-action Deny'
  }
}
