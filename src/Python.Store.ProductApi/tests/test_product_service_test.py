# tests/test_product_service.py
import unittest

from services.product_service import ProductService
from models.product import Product

class TestProductService(unittest.TestCase):
    def setUp(self):
        self.product_service = ProductService()

    def test_get_all_products(self):
        products = self.product_service.get_products()
        self.assertEqual(len(products), 3)
        self.assertEqual(products[0]['productName'], 'Product 1')
    
    def test_update_product(self):
        # Assuming the product to update has an ID of 1
        product_id = 1
        updated_product_data = {
            'productName': 'Updated Product 1',
            'price': 19.99
        }
        
        # Perform the update
        self.product_service.update_product(product_id, updated_product_data)
        
        # Verify the update
        updated_product = self.product_service.get_product_by_id(product_id)
        self.assertEqual(updated_product['productName'], 'Updated Product 1')
        self.assertEqual(updated_product['price'], 19.99)

if __name__ == '__main__':
    unittest.main()