from flask import Flask
from routes.products_routes import set_routes

app = Flask(__name__)

# Set up routes
set_routes(app)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
