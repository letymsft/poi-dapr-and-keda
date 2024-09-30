# Java Store Inventory API

## Overview

The Java Store Inventory API is a RESTful service designed to manage the inventory of a store. It provides endpoints to create, read, update, and delete inventory items. This API is implemented using Java and Spring Boot.

## Components

### 1. Project Structure

The project follows a standard Maven project structure:
    
    ```
    src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── example
    │   │           └── inventory
    │   │               ├── InventoryApplication.java
    │   │               ├── controller
    │   │               │   └── InventoryController.java
    │   │               ├── model
    │   │               │   └── InventoryItem.java
    │   │               └── service
    │   │                   └── InventoryService.java
    │   └── resources
    │       └── application.properties
    └── test
        └── java
            └── com
                └── example
                    └── inventory
                        ├── controller
                        │   └── InventoryControllerTest.java
                        └── service
                            └── InventoryServiceTest.java
                                                        
    
        
### 2. Key Components
    
#### Controller
    
    The controller package contains the REST controllers that handle HTTP requests and responses.
    
    - **InventoryController.java**: Defines the endpoints for managing inventory items.
    
#### Model
    
    The model package contains the entity classes that represent the data model.
    
    - **InventoryItem.java**: Represents an inventory item with fields like `id`, `name`, `quantity`, and `price`.
    
    #### Repository
    
    The repository package contains the interfaces for data access.
    
    - **InventoryRepository.java**: Extends `JpaRepository` to provide CRUD operations for `InventoryItem`.
    
#### Service
    
    The service package contains the business logic.
    
    - **InventoryService.java**: Provides methods to perform operations on inventory items, such as adding, updating, and deleting items.
    
    ### 3. Configuration
    
    The configuration is managed through the `application.properties` file located in the `src/main/resources` directory. This file contains settings for the database connection, server port, and other configurations.
    
    ### 4. Dependencies
    
    The project uses Maven for dependency management. Key dependencies include:
    
    - **Spring Boot Starter Web**: For building web applications.
    - **Spring Boot Starter Data JPA**: For data access using JPA.
    - **H2 Database**: An in-memory database for development and testing.
    - **Spring Boot Starter Test**: For testing the application.
    
### 5. Running the Application
    
#### Prerequisites
   
    - Java Development Kit (JDK) 11 or higher
    - Maven
    
#### Steps
    
    1. **Clone the repository**:
        ```sh
        git clone https://github.com/devsecopsadoptionmx/devsecopsdemo.git
        cd devsecopsdemo/src/Java.Store.InventoryApi
        ```
    
    2. **Build the project**:
        ```sh
        mvn clean install
        ```
    
    3. **Run the application**:
        ```sh
        mvn spring-boot:run
        ```
    
    4. **Access the API**:
        The API will be available at `http://localhost:8080`.
    
### 6. API Endpoints
    
    - **GET /inventory**: Retrieve all inventory items.
    - **GET /inventory/{id}**: Retrieve a specific inventory item by ID.
    - **POST /inventory**: Create a new inventory item.
    - **PUT /inventory/{id}**: Update an existing inventory item by ID.
    - **DELETE /inventory/{id}**: Delete an inventory item by ID.
    
### 7. Testing
    
    The project includes unit and integration tests located in the `src/test/java` directory. To run the tests, use the following command:
    
    ```sh
    mvn test

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



