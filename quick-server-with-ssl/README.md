# Quick Server with SSL
---

This directory contains configurartion for quickly setting up an Nginx server that is configured with SSL certificate.

## What we have here
In the `certs` directory we have the server certificate, key, and CA certificate
In the `conf` directory we have Nginx configuration

The `run-nginx.sh` runs Nginx docker container, putting configuration and certificates in place.

## Usage
1. Set up an entry in your `/etc/hosts` file:
```
127.0.0.1 example.com
```

2. Run the image
```
$ ./run-nginx.sh
```

3. Test
```
$ curl https://example.com:8443
```
