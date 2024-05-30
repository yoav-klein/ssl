#!/bin/bash

docker run --rm -p 8443:443 -p 8080:80 -d --name nginx -v $PWD/certs:/certs -v $PWD/conf/ssl.conf:/etc/nginx/conf.d/ssl.conf nginx
