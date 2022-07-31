# Debugging
---

In this demo, we'll run a nginx server with a server certificate.

Then, we'll use `openssl s_client` to test connection to that server.

First, source the `ssl_commons.sh` script

## Generate PKI
---

### Generate CA

Generate a CA

```
$ gen_ca_cert ca
```

This creates the `ca.crt` and `ca.key` files.

### Generate signing request

First, generate a private key:
```
$ gen_private_key
```

Now generate a CSR for the server:

```
$ gen_sign_request
```

Use the common name for the certificate: `my-server.com`

### Sign the request
Sign the request with the CA

```
$ sign_request server.csr ca.crt ca.key server.crt
```

## Run the Nginx Server
---

### Set up the container
Let's run a nginx docker container:
```
$ docker run -it nginx /bin/bash
$ mkdir /certs
```

And copy the certificate and key to the container:
```
$ docker cp server.key <containername>:/certs
$ docker cp server.crt <containername>:/certs
```

### Configure nginx to use a certificate
Now let's configure nginx to use a server certificate

Open the `/etc/nginx/conf.d/default.conf`, and add to the `server` section the following lines:
```
listen 443 # instead of 80
ssl on;
ssl_certificate /certs/server.crt;
ssl_certificate_key /certs/server.key;
```

### Run the server
Now run the server in the container:

```
$ nginx
```

## Test

Now we want to access the server from the machine. 
Take the IP of the container using `docker inspect`

Now put the following line in `/etc/hosts`

```
<container_ip>  my-server.com
```

Now it's money time. Let's access the server:
```
$ curl https://my-server.com
```

Oops, we got:
```
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.

```

This is because the server presented us a certifiate which is signed by an unkown CA.

Let's tell curl to trust the CA that signed this certificate:

```
$ curl --cacert ca.crt https://my-server.com
```

Bomba !

## Debug with openssl s_client
---

Let's use `openssl s_client` tool to debug the SSL connection to the server.

Run this:
```
$ openssl s_client -connect my-server:443
```

You should get this:
```
---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 1586 bytes and written 398 bytes
Verification error: unable to verify the first certificate
---

```

We can see that the verification of the certificate failed.

Now, let's specify the CA to trust:

```
$ openssl s_client -CAfile ca.crt -connect my-server:443
```

Now you should get:

```
--
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 1586 bytes and written 398 bytes
Verification: OK
---

```