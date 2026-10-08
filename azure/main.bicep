@description('The name of the Azure App Service for .NET 8 Backend')
param appName string = 'hackathon-backend-${uniqueString(resourceGroup().id)}'

@description('The Azure region where resources should be deployed')
param location string = resourceGroup().location

@description('App Service Plan pricing tier')
param sku string = 'B1'

@description('Container image name (e.g. ghcr.io/username/backend:latest or docker hub)')
param containerImage string = 'mcr.microsoft.com/dotnet/samples:aspnetapp'

@description('Port exposed by the container')
param containerPort string = '8080'

// 1. App Service Plan (Linux)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appName}-plan'
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
}

// 2. Web App for Containers (Linux)
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}'
      alwaysOn: false
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: containerPort
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ASPNETCORE_URLS'
          value: 'http://+:${containerPort}'
        }
      ]
    }
    httpsOnly: true
  }
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
