class Product:
    def __init__(self, productId, productName, quantity):
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
    def to_dict(self):
        return {
            'productId': self.productId,
            'productName': self.productName,
            'quantity': self.quantity
        }