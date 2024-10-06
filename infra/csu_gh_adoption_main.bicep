targetScope = 'subscription'

@description('Token replacements array with key value paris for string replacements.')
param tokenReplacements array

@description('Location for all resources.')
param location string = deployment().location

@description('List of resource groups. The substring "$ENV" will be replaced by the value of the parameter called "envMoniker".')
param resourceGr object

param containerRegistry object

param workspace object

param environment object

param identity object

param tags object

param inventory object

param product object

param portal object

param serviceBus object

param apiiniciativa object

param apiarquitectura object

param apipresupuesto object

var uniqueToken = toLower(take(uniqueString(subscription().id, environment.name, location), 5))

//////////////////////////////////////////////////////////// TOKEN REPLACEMENTS ////////////////////////////////////////////////////////////

func conditionalToLower(value string, valueToLower bool) string => valueToLower ? toLower(value) : value

func replaceAll(value string, replacements array, newStringtoLower bool) string =>
  conditionalToLower(
    reduce(
      replacements,
      value,
      (aggregate, currentReplacement) => replace(aggregate, currentReplacement.oldString, currentReplacement.newString)
    ),
    newStringtoLower
  )

var resourceGrName = replaceAll(resourceGr.name, tokenReplacements, false)

//////////////////////////////////////////////////////////// MODULES ////////////////////////////////////////////////////////////
module module_resourceGroup 'br/public:avm/res/resources/resource-group:0.2.4' = {
  name: 'pid-rg-${replaceAll(resourceGr.name, tokenReplacements, false)}-${uniqueToken}'
  params: {
    name: replaceAll(resourceGr.name, tokenReplacements, false)
    location: location
    tags: tags
  }
}

module module_workspace 'br/public:avm/res/operational-insights/workspace:0.4.1' = {
  name: 'pid-ws-${replaceAll(workspace.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(workspace.name, tokenReplacements, false)
    location: location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
  ]
}

module module_environment 'br/public:avm/res/app/managed-environment:0.5.2' = {
  name: 'pid-en-${replaceAll(environment.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(environment.name, tokenReplacements, false)
    logAnalyticsWorkspaceResourceId: module_workspace.outputs.resourceId
    location: location
    zoneRedundant: false
    tags: tags
    workloadProfiles: [
      {
        maximumCount: environment.maximumCount
        minimumCount: environment.minimumCount
        name: environment.workloadProfileName
        workloadProfileType: environment.workloadProfileType
      }
    ]
  }
  dependsOn: [
    module_resourceGroup
    module_workspace
  ]
}

module module_userIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  name: 'pid-id-${replaceAll(identity.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(identity.name, tokenReplacements, false)
    location: location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
  ]
}

module module_containerregistry 'br/public:avm/res/container-registry/registry:0.3.2' = {
  name: 'pid-cr-${replaceAll(containerRegistry.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: '${replaceAll(containerRegistry.name, tokenReplacements, true)}${uniqueToken}'
    acrSku: containerRegistry.acrSku
    location: location
    tags: tags
    roleAssignments: [
      {
        principalId: module_userIdentity.outputs.principalId
        principalType: identity.principalType //'ServicePrincipal'
        roleDefinitionIdOrName: identity.roleDefinitionIdOrName //'7f951dda-4ed3-4680-a7ca-43fe172d538d'
      }
    ]
  }
  dependsOn: [
    module_resourceGroup
    module_userIdentity
  ]
}

module containerAppInventory 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-inv-${replaceAll(inventory.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: inventory.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: inventory.name //'simple-hello-world-container'
        resources: {
          cpu: inventory.cpu //'1'
          memory: inventory.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: inventory.name
    location: location
    ingressExternal: inventory.ingressExternal
    ingressTargetPort: inventory.targetPort //8080
    disableIngress: inventory.disableIngress //false
    ingressTransport: inventory.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: inventory.scaleMaxReplicas
    scaleMinReplicas: inventory.scaleMinReplicas
    tags: tags
    managedIdentities: { userAssignedResourceIds: [module_userIdentity.outputs.resourceId] }
    registries: [
      {
        identity: module_userIdentity.outputs.resourceId
        server: module_containerregistry.outputs.loginServer
      }
    ]
  }
  dependsOn: [
    module_environment
  ]
}

module containerAppProduct 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-prod-${replaceAll(product.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: product.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: product.name //'simple-hello-world-container'
        resources: {
          cpu: product.cpu //'1'
          memory: product.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: product.name
    location: location
    ingressExternal: product.ingressExternal
    ingressTargetPort: product.targetPort //8080
    disableIngress: product.disableIngress //false
    ingressTransport: product.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: product.scaleMaxReplicas
    scaleMinReplicas: product.scaleMinReplicas
    tags: tags
    managedIdentities: { userAssignedResourceIds: [module_userIdentity.outputs.resourceId] }
    registries: [
      {
        identity: module_userIdentity.outputs.resourceId
        server: module_containerregistry.outputs.loginServer
      }
    ]
  }
  dependsOn: [
    module_environment
  ]
}

module containerAppPortal 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-por-${replaceAll(portal.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: portal.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: portal.name //'simple-hello-world-container'
        resources: {
          cpu: portal.cpu //'1'
          memory: portal.memory //0.5Gi'
        }
        env: [
          {
            name: 'InventoryApi'
            value: 'https://${containerAppInventory.outputs.fqdn}'
          }
          {
            name: 'ProductsApi'
            value: 'https://${containerAppProduct.outputs.fqdn}'
          }
          {
            name: 'ASPNETCORE_ENVIRONMENT'
            value: 'Development'
          }
        ]
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: portal.name
    location: location
    ingressExternal: portal.ingressExternal
    ingressTargetPort: portal.targetPort //8080
    disableIngress: portal.disableIngress //false
    ingressTransport: portal.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: portal.scaleMaxReplicas
    scaleMinReplicas: portal.scaleMinReplicas
    tags: tags
    managedIdentities: { userAssignedResourceIds: [module_userIdentity.outputs.resourceId] }
    registries: [
      {
        identity: module_userIdentity.outputs.resourceId
        server: module_containerregistry.outputs.loginServer
      }
    ]
  }
  dependsOn: [
    module_environment
  ]
}

////////////////////////////////////////Start infrastructure for DAPR & KEDA Demo////////////////////////////////////////
module module_servicebus 'br/public:avm/res/service-bus/namespace:0.1.0' = {
  name: 'pid-sb-${replaceAll(serviceBus.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: '${replaceAll(serviceBus.name, tokenReplacements, false)}-${uniqueToken}'
    location: location
    skuObject: {
      name: 'Standard'
    }
    topics: [
      {
        name: 'arquitecturapubsub'
        authorizationRules: [
          {
            name: 'RootManageSharedAccessKey'
            rights: [
              'Listen'
              'Manage'
              'Send'
            ]
          }
        ]
        subscriptions: [
          {
            name: 'apiarquitectura-subscription'
          }
        ]
      }
      {
        name: 'presupuestopubsub'
        authorizationRules: [
          {
            name: 'RootManageSharedAccessKey'
            rights: [
              'Listen'
              'Manage'
              'Send'
            ]
          }
        ]
        subscriptions: [
          {
            name: 'apipresupuesto-subscription'
          }
        ]
      }
      {
        name: 'ftppubsub'
        authorizationRules: [
          {
            name: 'RootManageSharedAccessKey'
            rights: [
              'Listen'
              'Manage'
              'Send'
            ]
          }
        ]
        subscriptions: [
          {
            name: 'ftp-subscription'
          }
        ]
      }
    ]
    tags: tags
  }

  dependsOn: [
    module_resourceGroup
  ]
}

module containerApiIniciativa 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-api-${replaceAll(apiiniciativa.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: apiiniciativa.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: apiiniciativa.name //'apiiniciativa'
        resources: {
          cpu: apiiniciativa.cpu //'1'
          memory: apiiniciativa.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: apiiniciativa.name
    location: location
    ingressExternal: apiiniciativa.ingressExternal
    ingressTargetPort: apiiniciativa.targetPort //8080
    disableIngress: apiiniciativa.disableIngress //false
    ingressTransport: apiiniciativa.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: apiiniciativa.scaleMaxReplicas
    scaleMinReplicas: apiiniciativa.scaleMinReplicas
    tags: tags
    managedIdentities: { userAssignedResourceIds: [module_userIdentity.outputs.resourceId] }
    dapr: {
      enabled: apiiniciativa.daprEnabled
      appId: apiiniciativa.daprAppId
      appProtocol: 'http'
      appPort: apiiniciativa.daprAppPort
    }
    registries: [
      {
        identity: module_userIdentity.outputs.resourceId
        server: module_containerregistry.outputs.loginServer
      }
    ]
  }
  dependsOn: [
    module_environment
  ]
}

module containerApiArquitectura 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-api-${replaceAll(apiarquitectura.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: apiarquitectura.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: apiarquitectura.name //'apiarquitectura'
        resources: {
          cpu: apiarquitectura.cpu //'1'
          memory: apiarquitectura.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: apiarquitectura.name
    location: location
    ingressExternal: apiarquitectura.ingressExternal
    ingressTargetPort: apiarquitectura.targetPort //8080
    disableIngress: apiarquitectura.disableIngress //false
    ingressTransport: apiarquitectura.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: apiarquitectura.scaleMaxReplicas
    scaleMinReplicas: apiarquitectura.scaleMinReplicas
    tags: tags
    managedIdentities: { userAssignedResourceIds: [module_userIdentity.outputs.resourceId] }
    dapr: {
      enabled: apiarquitectura.daprEnabled
      appId: apiarquitectura.daprAppId
      appProtocol: 'http'
      appPort: apiarquitectura.daprAppPort
    }
    registries: [
      {
        identity: module_userIdentity.outputs.resourceId
        server: module_containerregistry.outputs.loginServer
      }
    ]
  }
  dependsOn: [
    module_environment
  ]
}

module containerApiPresupuesto 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-api-${replaceAll(apipresupuesto.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: apipresupuesto.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: apipresupuesto.name //'apipresupuesto'
        resources: {
          cpu: apipresupuesto.cpu //'1'
          memory: apipresupuesto.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: apipresupuesto.name
    location: location
    ingressExternal: apipresupuesto.ingressExternal
    ingressTargetPort: apipresupuesto.targetPort //8080
    disableIngress: apipresupuesto.disableIngress //false
    ingressTransport: apipresupuesto.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: apipresupuesto.scaleMaxReplicas
    scaleMinReplicas: apipresupuesto.scaleMinReplicas
    tags: tags
    managedIdentities: { userAssignedResourceIds: [module_userIdentity.outputs.resourceId] }
    dapr: {
      enabled: apipresupuesto.daprEnabled
      appId: apipresupuesto.daprAppId
      appProtocol: 'http'
      appPort: apipresupuesto.daprAppPort
    }
    registries: [
      {
        identity: module_userIdentity.outputs.resourceId
        server: module_containerregistry.outputs.loginServer
      }
    ]
  }
  dependsOn: [
    module_environment
  ]
}
/////////////////////////////////////////End infrastructure for DAPR & KEDA Demo/////////////////////////////////////////
