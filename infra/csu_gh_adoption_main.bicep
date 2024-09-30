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


//////////////////////////////////////////////////////////// TOKEN REPLACEMENTS ////////////////////////////////////////////////////////////

func conditionalToLower(value string, valueToLower bool) string => valueToLower ? toLower(value) : value

func replaceAll(value string, replacements array, newStringtoLower bool) string => conditionalToLower(
  reduce(
    replacements,
    value,
    (aggregate, currentReplacement) => replace(aggregate, currentReplacement.oldString, currentReplacement.newString)),
  newStringtoLower)

var resourceGrName = replaceAll(resourceGr.name, tokenReplacements, false)

//////////////////////////////////////////////////////////// MODULES ////////////////////////////////////////////////////////////
module module_resourceGroup 'br/public:avm/res/resources/resource-group:0.2.4' = {
  name: 'pid-rg-${replaceAll(resourceGr.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  params: {
    name: replaceAll(resourceGr.name, tokenReplacements, false)
    location: location
    tags: tags
  }
}



module module_workspace 'br/public:avm/res/operational-insights/workspace:0.4.1' = {
  name: 'pid-ws-${replaceAll(workspace.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(workspace.name, tokenReplacements, false)
    location:location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
  ]
}

module module_environment 'br/public:avm/res/app/managed-environment:0.5.2' = {
  name: 'pid-en-${replaceAll(environment.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(environment.name, tokenReplacements, false)
    logAnalyticsWorkspaceResourceId: module_workspace.outputs.resourceId
    location:location
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
  name: 'pid-id-${replaceAll(identity.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
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
  name: 'pid-cr-${replaceAll(containerRegistry.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: '${replaceAll(containerRegistry.name, tokenReplacements, true)}-${uniqueString(deployment().name)}'
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
  name: 'pid-inv-${replaceAll(inventory.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: inventory.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: inventory.name//'simple-hello-world-container'
        resources: {
          cpu: inventory.cpu//'1'
          memory: inventory.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: inventory.name
    location: location
    ingressExternal: inventory.ingressExternal
    ingressTargetPort: inventory.targetPort  //8080
    disableIngress: inventory.disableIngress //false
    ingressTransport: inventory.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: inventory.scaleMaxReplicas
    scaleMinReplicas: inventory.scaleMinReplicas
    tags: tags
    managedIdentities: {userAssignedResourceIds: [module_userIdentity.outputs.resourceId]}
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
  name: 'pid-prod-${replaceAll(product.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: product.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: product.name//'simple-hello-world-container'
        resources: {
          cpu: product.cpu//'1'
          memory: product.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: product.name
    location: location
    ingressExternal: product.ingressExternal
    ingressTargetPort: product.targetPort  //8080
    disableIngress: product.disableIngress //false
    ingressTransport: product.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: product.scaleMaxReplicas
    scaleMinReplicas: product.scaleMinReplicas
    tags: tags
    managedIdentities: {userAssignedResourceIds: [module_userIdentity.outputs.resourceId]}
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
  name: 'pid-por-${replaceAll(portal.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: portal.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: portal.name//'simple-hello-world-container'
        resources: {
          cpu: portal.cpu//'1'
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
    ingressTargetPort: portal.targetPort  //8080
    disableIngress: portal.disableIngress //false
    ingressTransport: portal.ingressTransport //'http'
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: portal.scaleMaxReplicas
    scaleMinReplicas: portal.scaleMinReplicas
    tags: tags
    managedIdentities: {userAssignedResourceIds: [module_userIdentity.outputs.resourceId]}
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
