#!/bin/python

## script to fetch data from https://dummyjson.com/products and filter products ###
## with price and create a file and upload to aws s3 bucket.###
import requests
import json
import subprocess

jason_data = requests.get('https://dummyjson.com/products')
content = jason_data.json()

if 'products' in content:
    for product in content['products']:
        if product.get('price', 0) >= 100:
            data = (json.dumps(product, indent=4))
            with open ('new_products.json', 'a') as f:
                f.write(data)

else:
    print("No products found.")

command =  "aws s3 cp new_products s3://checkpoint-assignment-prod/"
subprocess.run(command, shell=True)
print("File uploaded to S3 bucket successfully.")
