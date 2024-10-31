# DAPR&KEDAIlluminationPath

![Model](https://github.com/letymsft/poi-dapr-and-keda/blob/main/images/ArchitectureDiagram.jpg)

## Here are the rules
1. You don’t talk about Fight Club
2. Solve problems at your pace
3. You’ll get a coin 🪙 for every problem solved
4. Special problems gives you 3 coins 🪙🪙🪙      
5. Guaranteed swag on your first coin
6. Swag on the total coin mark
7. Special swag to every finisher
8. Special swag to the first place (time + coins)

## Prerequisites
* An Azure subscription

### Task 1 🪙
Fork this repo.
Follow the below steps in your forked repo.

### Task 2 🪙
Create a service principal which role be contributor in your Azure subscription.

### Task 3 🪙
Create the "AZURE_CREDENTIALS" secret in GitHub using the service principal info from the previous step:
{
  "clientId": "XXXXX",
  "clientSecret": "XXXXX",
  "subscriptionId": "XXXXX",
  "tenantId": "XXXXX"
}

### Task 4 🪙
Create next variables in GitHub;
LOCATION=centralus
RESOURCE_GROUP=CUS-CSU-DEV-GHADOP-RGP

### Task 5 🪙
In GitHub, go to Actions -> All Workflows and run the workflow "IAC DEV DEPLOYMENT".

### Task 6 🪙
Once the previous execution has finished successfully, run the workflow "DAPR_KEDA_DEV".

### Task 7 🪙
Once the previous execution has finished successfully, run the workflows:
* ACA DEV API Arquitectura
* ACA DEV API Iniciativa
* ACA DEV API Presupuesto
Once all the previous executions have finished, wait for 2-3 minutes to continue with the next step.

### Task 8 🪙
In Azure Portal, go to resource group "CUS-CSU-DEV-GHADOP-RGP", and find the "apiiniciativa" container app created onto it. Copy the Login Server value.

### Task 9 🪙
Execute the below call using the Login Server value.
curl --location 'https://{Use your Login Server here}/api/iniciativa/createiniciativa' \
--header 'Content-Type: application/json' \
--data '{
    "NombreIniciativa":"Iniciativa 1",
    "UserId":"user",
    "Arquitectura":{
        "NombreArquitectura":"Arquitectura1"
    },
    "Presupuesto":{
        "NombrePresupuesto":"Presupuesto1"
    }
}'

### Task 10 🪙
In Azure Portal, monitor the Log stream from apiiniciativa, apiarquitectura and apipresupuetos containers

### Task 11 🪙
In Azure Portal, monitor the content of subscription "ftp-subscription" from topic "ftppubsub" in the Service Bus.

## Challenges
### DAPR 🪙🪙🪙
You can use Copilot to create an API with Azure Container App and enable DAPR on it. Use the subscription "ftp-subscription" from topic "ftppubsub".

### KEDA 🪙🪙🪙
Enable auto-scaling for the container app 'apiarquitectura' based on Service Bus messages from the 'arquitecturapubsub' topic and the 'apiarquitectura' subscription. 
> [!TIP]
> It is necessary to create a secret for the Service Bus in the 'apiarquitectura' container application.
