from models.product import Product
import uuid

class ProductService:
    def __init__(self):
        self.products = [
            Product(str(uuid.uuid4()), 'Product 1', 10),
            Product(str(uuid.uuid4()), 'Product 2', 20),
            Product(str(uuid.uuid4()), 'Product 3', 30),
        ]
        

    def get_products(self):
        return [product.to_dict() for product in self.products]

    def get_product(self, product_id):
        return next((product.to_dict() for product in self.products if product.productId == product_id), None)

    def create_product(self, product_data):        
        new_product = Product(product_data['productId'], product_data['productName'], product_data['quantity'])
        self.products.append(new_product)
        return new_product.to_dict()

    def update_product(self, product_id, product_data):
        for product in self.products:
            if product.productId == product_id:
                product.productName = product_data['productName']
                product.quantity = product_data['quantity']
                return product.to_dict()
        return None        

    def delete_product(self, product_id):
        for product in self.products:
            if product.productId == product_id:
                self.products.remove(product)
            return True
        return False        