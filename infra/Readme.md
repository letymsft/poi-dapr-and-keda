# Infra

This folder contains the infrastructure as code (IaC) for the DemoGHAdopcion-CSUMexico project. It uses Bicep to define and deploy Azure resources.

## Description

The `infra` folder includes Bicep templates and parameter files to provision and manage the necessary Azure infrastructure for the project. 

## File Description
`csu_ghadoption_main.bicep` This file is the main Bicep template that defines the infrastructure resources for the DemoGHAdopcion-CSUMexico project. It orchestrates the deployment of various Azure resources such Azure Container Apps, Container Registry, etc. This template serves as the entry point for provisioning and managing the project's infrastructure using Bicep.

`csu_gh_adoption_dev.json` This file contains the configuration settings for the development environment of the CSU GitHub Adoption project.
It includes various parameters and values that are used to customize the behavior of the application during development.
The configuration settings in this file should be modified according to the specific requirements of the development environment.

`csu_gh_adoption_prod.json` This file contains the configuration settings for the productionenvironment of the CSU GitHub Adoption project.
It includes various parameters and values that are used to customize the behavior of the application during development.
The configuration settings in this file should be modified according to the specific requirements of the development environment.

`bicepconfig.json` This file is used to configure the behavior of the Bicep compiler and deployment process. It includes settings such as the target Azure subscription, resource group, and deployment mode. The configuration in this file determines how the Bicep templates in the `infra` folder are compiled and deployed to Azure. It is important to review and update the settings in this file to ensure the correct deployment of the infrastructure resources for the DemoGHAdopcion-CSUMexico project.