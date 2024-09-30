
from flask import Blueprint, jsonify
from services.product_service import ProductService

product_service = ProductService()
products_bp = Blueprint('products', __name__, url_prefix='/products')

class ProductsController:

    @products_bp.route('/', methods=['GET'])
    def get_products():
        # Logic to retrieve all products from the database
        products = product_service.get_products()

        # Return the products as JSON response
        return jsonify(products), 200        
    @products_bp.route('/<uuid:product_id>', methods=['GET']) 
    def get_product(product_id):
        # Logic to retrieve a specific product from the database
        product = product_service.get_product(product_id)

        if product is None:
            # Return a 404 error if the product is not found
            return jsonify({'error': 'Product not found'}), 404

        # Return the product as JSON response
        return jsonify(product), 200
    

    @products_bp.route('/', methods=['POST'])
    def create_product( product_data):
        # Logic to create a new product in the database
        product = product_service.create_product(product_data)

        # Return the created product as JSON response
        return jsonify(product), 201

    @products_bp.route('/<uuid:product_id>', methods=['PUT'])
    def update_product( product_id, product_data):
        # Logic to update a specific product in the database
        product = product_service.update_product(product_id, product_data)

        if product is None:
            # Return a 404 error if the product is not found
            return jsonify({'error': 'Product not found'}), 404

        # Return the updated product as JSON response
        return jsonify(product),201

    @products_bp.route('/<uuid:product_id>', methods=['DELETE'])
    def delete_product( product_id):
        # Logic to delete a specific product from the database
        result = product_service.delete_product(product_id)

        if result is False:
            # Return a 404 error if the product is not found
            return jsonify({'error': 'Product not found'}), 404

        # Return a success message as JSON response
        return jsonify({'message': 'Product deleted'}), 201