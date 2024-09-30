# tests/test_products_controller.py
import unittest
from flask import Flask
from controllers.products_controller import products_bp

class TestProductsController(unittest.TestCase):
    def setUp(self):
        self.app = Flask(__name__)
        self.app.register_blueprint(products_bp)
        self.client = self.app.test_client()

    def test_get_products(self):
        response = self.client.get('/products/', follow_redirects=True)  # Include trailing slash and follow redirects
        self.assertEqual(response.status_code, 200)  # Check for 200 OK status code
        products = response.json  # Directly access the JSON response
        self.assertIsNotNone(products)  # Ensure the response is not None
        self.assertEqual(len(products), 3)        
        self.assertEqual(products[0]['productName'], 'Product 1')

if __name__ == '__main__':
    unittest.main()