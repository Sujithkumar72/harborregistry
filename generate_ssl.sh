#!/usr/bin/env bash
openssl version
if [ $? -eq 0 ]
then
mkdir -pv certs
cd certs
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650  -subj "/C=IN/ST=IN/L=MAS/O=test/OU=ops/CN=test.ca"  -key ca.key  -out ca.crt
read -sp "Enter your domain name : " domain
openssl genrsa -out $domain.key 4096
openssl req -sha512 -new     -subj "/C=IN/ST=IN/L=MAS/O=test/OU=ops/CN=$domain"     -key $domain.key     -out $domain.csr
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$domain
EOF
openssl x509 -req -sha512 -days 3650     -extfile v3.ext     -CA ca.crt -CAkey ca.key -CAcreateserial     -in $domain.csr     -out $domain.crt

rm -rf ca.key v3.ext $domain.csr ca.srl
echo "##################################################"
echo "#  All Required SSL files generated successfully #"
echo "##################################################"

else
	echo "#################################################"
	echo "# please install openssl and execute the script #"
	echo "#################################################"

fi
