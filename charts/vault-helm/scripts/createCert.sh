#!/bin/bash

set -euo pipefail 

# check if we have openssl
if ! openssl -v > /dev/null 2>&1; then 
  echo "Openssl is required for the script, actually its not installed. Exitting."
  exit 1
fi

# requesting info needed for cert creation
read -p "Enter the RootCA file name: " rootca
read -p "Enter the RootCA key file name: " rootcakey
read -p "Enter the certificate validation period in days: " certlife
read -p "Enter the FQDN: " fqdn
read -p "Enter the SANs (delimited by space): " sans

vault_instance=$(echo $fqdn | cut -f 1 -d ".")
# prepare SANs
count=2
altnames=""
altnames=$(for san in $sans; do
  echo "DNS.$count = $san"
  ((count++))
done)

# create the certificate key
if ! openssl genrsa -out ${vault_instance}.key 2048; then
  echo "Cannot generate certificate key."
  exit 1
fi

# prepare configuration for CSR
cat <<EOF > ${vault_instance}.cnf
[req]
default_bits = 2048
prompt = no
encrypt_key = yes
default_md = sha256
distinguished_name = req_dn
req_extensions = v3_req

[req_dn]
CN = ${fqdn}

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = ${fqdn}
${altnames}
EOF

# create CSR
if ! openssl req -new -nodes -key ${vault_instance}.key -config ${vault_instance}.cnf -out ${vault_instance}.csr; then
  echo "Problem with createing the CSR."
  exit 1
fi

# create certificate
if ! openssl x509 -req -in ${vault_instance}.csr -days ${certlife} -CA ${rootca} -CAkey ${rootcakey} -CAcreateserial -extensions v3_req -out ${vault_instance}.crt -extfile ${vault_instance}.cnf; then
  echo "Problem creating the certificate."
  exit 1
fi

# verify created cert
if ! openssl verify -CAfile ${rootca} ${vault_instance}.crt; then
  echo "Certificate is not valid, there had to be some problem during cert creation."
  exit 1
else
  echo "Certificate verified and ready for use."
  echo "The content of certificate is: "
  openssl x509 -in ${vault_instance}.crt -noout -text
fi

