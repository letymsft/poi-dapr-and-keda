# Products API

This project is a Python-based API that exposes endpoints for managing products.

## Project Structure

The project has the following files and directories:

- `src/`: The source code directory.
  - `__init__.py`: Marks the `src` directory as a Python package.
  - `app.py`: Entry point of the application. Creates an instance of the Flask app and sets up the routes.
  - `controllers/`: Directory for the controllers.
    - `__init__.py`: Marks the `controllers` directory as a Python package.
    - `products_controller.py`: Handles the HTTP methods for the products API.
  - `models/`: Directory for the models.
    - `__init__.py`: Marks the `models` directory as a Python package.
    - `product.py`: Represents the product model.
  - `routes/`: Directory for the routes.
    - `__init__.py`: Marks the `routes` directory as a Python package.
    - `products_routes.py`: Sets up the routes for the products API.
  - `services/`: Directory for the services.
    - `__init__.py`: Marks the `services` directory as a Python package.
    - `product_service.py`: Provides methods for interacting with the product data.
- `requirements.txt`: Lists the dependencies required for the project.
- `tests/`: Directory for the unit tests.
  - `__init__.py`: Marks the `tests` directory as a Python package.
  - `test_product_service.py`: Unit tests for the product service.
- `.gitignore`: Specifies files and directories to be ignored by Git.
- `LICENSE`: The license for the project.
- `Dockerfile`: Configuration file for building a Docker image.
- `README.md`: Documentation for the project.

## Getting Started

To set up and run the project, follow these steps:

1. Clone the repository.
2. Install the required dependencies by running `pip install -r requirements.txt`.
3. Run the application by executing `python src/app.py`.
4. The API will be accessible at `http://localhost:5000`.
5. To run the unit test please make sure first to configure the PYTHONPATH  to the root of the project and then run the following commands `export PYTHONPATH=$(pwd)/src` and then `python -m unittest discover -s tests -p "*_test.py"`.

## API Endpoints

The following endpoints are available:

- `GET /products`: Retrieves all products.
- `GET /products/{id}`: Retrieves a specific product by ID.
- `POST /products`: Creates a new product.
- `PUT /products/{id}`: Updates an existing product.
- `DELETE /products/{id}`: Deletes a product.

For detailed information about each endpoint and the expected request and response formats, refer to the API documentation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
```

Please note that the above contents are a template and you may need to modify them according to your specific project requirements.