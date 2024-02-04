metadata description = 'Creates an Azure App Configuration store.'
param name string
param location string = resourceGroup().location
param tags object = {}
param connectionStringKey string = 'AZURE-COSMOS-CONNECTION-STRING'

@description('Specifies the names of the key-value resources. The name is a combination of key and label with $ as delimiter. The label is optional.')
param keyValueNames array = []

@description('Specifies the values of the key-value resources.')
param keyValueValues array = []

@description('Specifies the URI of the Key Vault that contains the secret.')
param keyVaultURI string

var keyVaultRef = {
  uri: '${keyVaultURI}secrets/${connectionStringKey}'
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  tags: tags
}

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [for (item, i) in keyValueNames: {
  parent: configStore
  name: item
  properties: {
    value: keyValueValues[i]
    tags: tags
  }
}]

resource configStoreSecretReference 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStore
  name: 'AZURE_COSMOS_CONNECTION_STRING$todo-api'
  properties: {
    value: string(keyVaultRef)
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

output endpoint string = configStore.properties.endpoint
