from flask import Blueprint, jsonify, request
from controllers.products_controller import products_bp

def set_routes(app):
    app.register_blueprint(products_bp)