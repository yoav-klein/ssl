#!/bin/bash


openssl genrsa -out ca.key
openssl req -new -x509 -days 365 -config ca.conf -key ca.key -out ca.crt
