# tests/test_product_model.py
import unittest
import uuid
from models.product import Product

class TestProductModel(unittest.TestCase):
    def test_product_creation(self):
        product = Product(1, 'Product 1', 10)
        self.assertEqual(product.productId, 1)
        self.assertEqual(product.productName, 'Product 1')
        self.assertEqual(product.quantity, 10)

    def test_product_to_dict(self):
        guid= str(uuid.uuid4())
        product = Product(guid, 'Product 1', 10)
        product_dict = product.to_dict()
        self.assertEqual(product_dict, {'productId': guid, 'productName': 'Product 1', 'quantity': 10})

if __name__ == '__main__':
    unittest.main()