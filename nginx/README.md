

# Run Nginx with TLS certificate
---

This is a demonstration of running a Nginx server with a TLS certificate.

## Description

### Generate PKI
First, we need to generate a certificate. For this, we need a CA to sign it.
So what we do is:
1. Generate a CA key and certificate
2. Generate a CSR for our server
3. Sign the CSR with the CA


For this, we'll use the functions in the `ssl_functions.sh` script.

Note that in the CN of the server's certificate, we need to use the IP to which we'll try to connect, so give it `172.17.0.2`,
assuming this will be the IP of the container.

### Run Nginx Server
Now that we have the PKI ready, we want to run the server with the certificate.
For this, we have a Dockerfile that's based on `nginx` image. We copy our certificate and private key
to a specific location, and edit the `/etc/nginx/conf.d/default.conf` file to configure the server to 
use TLS and tell it where the certificate and key are.

```
$ docker build -t nginx:0.1 .
```

Now, let's run our server:
```
$ docker run -d nginx:0.1
```

### Install the CA certificate
In order for us to be able to browse to our server with TLS, we need to install the CA certificate so our browser (or curl) will trust it:


First, copy the `ca.crt` file to `/usr/local/share/ca-certificates`
```
$ sudo cp ca.crt /usr/local/share/ca-certificates
```

Now run:
```
$ sudo update-ca-certificates
```

### Test
Finally, let's try to see if it works:
```
$ curl https://172.17.0.2:443
```

## Notes
Note that in order for the client to accept the certificate, the CN (Common Name) of the certificate must match
the host name/domain name to which the client tried to connect to. So we give it the IP of the container that will run our server.


