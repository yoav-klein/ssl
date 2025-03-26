# SSL Utils Script
---

This is a python script that helps you diagnose SSL issues
It provides the following functions:
- List certificates  in a directory or a bundle
- Find a certificate in a directory or a bundle based on CN

## Examples

```
$ python3 ssl_utils.py list-certs --type dir --path examples/directory
```

```
$ python3 ssl_utils.py list-certs --type bundle --path examples/ca-certificates.crt
```

```
$ python3 ssl_utils.py find-cert --type dir --path examples/directory --cn MyCompany
```

```
$ python3 ssl_utils.py find-cert --type bundle --path examples/ca-certificates.crt --cn MyCompany
```