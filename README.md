docker-devbox-cfssl
===================

CFSSL docker-compose configuration to use with docker-devbox.

It allows to generate certificates from a 3 level chain (Root CA, Intermediate CA, End-User CA)

Installation
------------
```
docker-compose up
```

Generate a wildcard certificate for a domain name
--------------------------------------------------
- From server shell

```
dc exec intermediate sh
H=eqo.app # Domaine name of the certificate
cfssl gencert -ca ca.pem -ca-key ca-key.pem -hostname "$H,*.$H" ca_intermediate_config.json | cfssljson -bare "$H"
cat ca.pem >> "$H.pem"
exit
```

- From REST API with [cfssl-cli](https://github.com/Toilal/python-cfssl-cli)

Get the root certificate to add to client truststore
----------------------------------------------------
- From server shell

```
dc exec root cat /etc/cfssl/ca.pem
```
