# To generate JWT keys

openssl genrsa -sha256 -out private_key_2.pem 2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
