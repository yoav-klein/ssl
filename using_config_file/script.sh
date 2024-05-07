#!/bin/bash
private_key=demo.key
csr=demo.csr
ca=myca
cert=server.crt

# create private key and CSR
openssl genrsa -out $private_key 2048
openssl req -new -key $private_key -subj="/CN=*.yoav.net" -out $csr -config ssl.conf -reqexts v3_req

# another alternative - using -addext option
#openssl req -new -sha384  -addext subjectAltName=DNS.1:*.yoav-klein.com,DNS.2:yoav-klein.com -subj="/CN=yoav-klein.com" -key $private_key -out $csr

# gen CA

openssl genrsa -out $ca.key 2048
openssl req -new -subj "/CN=*.my.authority" -x509 -days 365 -key $ca.key -sha256 -out $ca.cert

# sign request
openssl x509 -req -days 365 -sha256 -in $csr -CA $ca.cert -CAkey $ca.key \
    	-CAcreateserial -out $cert 
        

#-extfile $ext_file -extensions $extensions
