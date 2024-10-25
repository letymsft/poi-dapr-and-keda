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

param serviceBus object

param apiiniciativa object

param apiarquitectura object

param apipresupuesto object

param loadtesting object

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

////////////////////////////////////////Start infrastructure for DAPR & KEDA Demo////////////////////////////////////////
module module_servicebus 'br/public:avm/res/service-bus/namespace:0.9.0' = {
  name: 'pid-sb-${replaceAll(serviceBus.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: '${replaceAll(serviceBus.name, tokenReplacements, false)}-${uniqueToken}'
    location: location
    tags: tags
    skuObject: {
      name: 'Premium'
    }
    roleAssignments: [
      {
        principalId: containerApiIniciativa.outputs.systemAssignedMIPrincipalId
        roleDefinitionIdOrName: 'Azure Service Bus Data Sender'
      }
      {
        principalId: containerApiArquitectura.outputs.systemAssignedMIPrincipalId
        roleDefinitionIdOrName: 'Azure Service Bus Data Owner'
      }
      {
        principalId: containerApiPresupuesto.outputs.systemAssignedMIPrincipalId
        roleDefinitionIdOrName: 'Azure Service Bus Data Owner'
      }
    ]
    topics: [
      {
        name: 'arquitecturapubsub'
        roleAssignments: []
        subscriptions: []
        authorizationRules: []
      }
      {
        name: 'presupuestopubsub'
        roleAssignments: []
        subscriptions: []
        authorizationRules: []
      }
      {
        name: 'ftppubsub'
        roleAssignments: []
        subscriptions: [
          {
            name: 'ftp-subscription'
          }
        ]
        authorizationRules: []
      }
    ]
  }

  dependsOn: [
    module_resourceGroup
  ]
}

module containerApiIniciativa 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-api-${replaceAll(apiiniciativa.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    containers: [
      {
        image: apiiniciativa.image
        name: apiiniciativa.name
        resources: {
          cpu: apiiniciativa.cpu
          memory: apiiniciativa.memory
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: apiiniciativa.name
    location: location
    ingressExternal: apiiniciativa.ingressExternal
    ingressTargetPort: apiiniciativa.targetPort
    disableIngress: apiiniciativa.disableIngress
    ingressTransport: apiiniciativa.ingressTransport
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: apiiniciativa.scaleMaxReplicas
    scaleMinReplicas: apiiniciativa.scaleMinReplicas
    tags: tags
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [module_userIdentity.outputs.resourceId]
    }
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
    module_containerregistry
  ]
}

module containerApiArquitectura 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-api-${replaceAll(apiarquitectura.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    containers: [
      {
        image: apiarquitectura.image
        name: apiarquitectura.name
        resources: {
          cpu: apiarquitectura.cpu
          memory: apiarquitectura.memory
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: apiarquitectura.name
    location: location
    disableIngress: apiarquitectura.disableIngress
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: apiarquitectura.scaleMaxReplicas
    scaleMinReplicas: apiarquitectura.scaleMinReplicas
    tags: tags
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [module_userIdentity.outputs.resourceId]
    }
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
    module_containerregistry
  ]
}

module containerApiPresupuesto 'br/public:avm/res/app/container-app:0.7.0' = {
  name: 'pid-api-${replaceAll(apipresupuesto.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    containers: [
      {
        image: apipresupuesto.image
        name: apipresupuesto.name
        resources: {
          cpu: apipresupuesto.cpu
          memory: apipresupuesto.memory
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: apipresupuesto.name
    location: location
    disableIngress: apipresupuesto.disableIngress
    workloadProfileName: environment.workloadProfileName
    scaleMaxReplicas: apipresupuesto.scaleMaxReplicas
    scaleMinReplicas: apipresupuesto.scaleMinReplicas
    tags: tags
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [module_userIdentity.outputs.resourceId]
    }
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
    module_containerregistry
  ]
}
/////////////////////////////////////////End infrastructure for DAPR & KEDA Demo/////////////////////////////////////////

/////////////////////////////////////////Start infrastructure for load testing///////////////////////////////////////////
module loadTestingComponent 'br/public:avm/res/load-test-service/load-test:0.3.0' = {
  name: 'pid-api-${replaceAll(loadtesting.name, tokenReplacements, false)}-${uniqueToken}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: apiiniciativa.loadTesting.name
    location: location
  }
}
//////////////////////////////////////////End infrastructure for load testing///////////////////////////////////////////
