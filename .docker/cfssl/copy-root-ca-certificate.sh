#!/usr/bin/env sh

# If a volume is mounted in /rootca, copy the ca certificate
CA_ROOT_URI=${CA_ROOT_URI-/etc/cfssl/ca.pem}
echo "$CA_ROOT_URI"
ls -al /

echo "id: $(id)"

if [ -f "$CA_ROOT_URI" ] && [ -d "/rootca" ]; then
  cp -f "$CA_ROOT_URI" "/rootca/rootCA.pem"
  echo "Root CA has been copied to /rootca"
fi
