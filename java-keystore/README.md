# Java KeyStore
---

Java has a Trust Store of its own with a list of CA certificates that Java applications trust.

This directory includes a simple Java program that initiates a connection to a URL. This can help
you know if your Java installation trusts a certificate served by a website.

## Usage
---

```
$ java Main <url>
```

If your CA is not installed in the key store, you'll get:
```
 javax.net.ssl.SSLHandshakeException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
```
