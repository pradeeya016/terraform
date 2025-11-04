#!/bin/python
import requests
import json

jason_data = requests.get('https://dummyjson.com/products')
content = jason_data.json()

if 'products' in content:
    for product in content['products']:
        if product.get('price', 0) >= 100:
            data = (json.dumps(product, indent=4))
            with open ('new_products', 'a') as f:
                f.write(data)