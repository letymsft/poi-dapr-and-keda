"# DemoGHAdopcion-CSUMexico" 
TEST+

[![DEV IAC VALIDATION](https://github.com/devsecopsadoptionmx/devsecopsdemo/actions/workflows/BICEP_DEV_PullRequest.yml/badge.svg)](https://github.com/devsecopsadoptionmx/devsecopsdemo/actions/workflows/BICEP_DEV_PullRequest.yml)

## Overview

This repository contains a demonstration of a DevSecOps adoption project for CSU Mexico. The solution is designed to showcase best practices in infrastructure as code (IaC), continuous integration/continuous deployment (CI/CD), and security integration.

## Components

### 1. Infrastructure as Code (IaC)

The infrastructure is defined using Bicep, a domain-specific language (DSL) for deploying Azure resources declaratively. The IaC scripts are located in the `iac/` directory and include:

- **Main Bicep File**: Defines the core infrastructure components.
- **Modules**: Reusable Bicep modules for specific resources.
- **Parameter Files**: Configuration files for different environments (e.g., dev, staging, production).

### 2. CI/CD Pipelines

The CI/CD pipelines are configured using GitHub Actions. The workflows are located in the `.github/workflows/` directory and include:

- **BICEP_DEV_PullRequest.yml**: Validates the Bicep templates on pull requests to the development branch.
- **BICEP_DEV_Deploy.yml**: Deploys the infrastructure to the development environment.
- **BICEP_PROD_Deploy.yml**: Deploys the infrastructure to the production environment.

### 3. Application Code

The application code is organized into three main directories:

- **src/Store**: Blazor Server front-end web app to display product information, implemented in .NET ![Readme](https://github.com/devsecopsadoptionmx/devsecopsdemo/blob/dev/src/Store/Readme.md)
- **src/Python.Store.ProductApi**: Contains the source code for the Product API, implemented in Python. ![Readme](https://github.com/devsecopsadoptionmx/devsecopsdemo/blob/dev/src/Python.Store.ProductApi/README.md)
- **src/Java.Store.InventoryApi**: Contains the source code for the Inventory API, implemented in Java.![Readme](https://github.com/devsecopsadoptionmx/devsecopsdemo/blob/dev/src/Java.Store.InventoryApi/Readme.md)

### 4. Security Integration

Security is integrated into the CI/CD pipelines to ensure that the code and infrastructure are secure. This includes:

- **Static Code Analysis**: Tools like SonarQube are used to analyze the code for vulnerabilities.
- **Dependency Scanning**: Tools like Dependabot are used to scan for vulnerable dependencies.
- **Infrastructure Security**: Azure Policy and Security Center are used to enforce security best practices on the deployed resources.

## Getting Started

### Prerequisites

- Azure Subscription
- GitHub Account
- Bicep CLI
- Python and Java Development Environments

### Setup

1. **Clone the repository**:
	```sh
	git clone https://github.com/devsecopsadoptionmx/devsecopsdemo.git
	cd devsecopsdemo
	```

2. **Configure Azure CLI**:
	```sh
	az login
	```

3. **Deploy the infrastructure**:
	```sh
	az deployment group create --resource-group <resource-group-name> --template-file iac/main.bicep
	```

4. **Run the application**:
	- Navigate to the `src/Python.Store.ProductApi` and `src/Java.Store.InventoryApi` directories and follow the respective README files for running the applications.

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Special thanks to the CSU Mexico team for their support and collaboration.
- Thanks to the open-source community for providing the tools and resources that made this project possible.
