#!/bin/sh
#
echo -i Create certs per user
#
CA_PATH=$( dirname ${BASH_SOURCE[0]})
#
user=$1
customer=$2
location=$3
#
# Process keystores for each user
#
keytool -genkey -noprompt \
    -alias ${user} \
    -dname "CN=${user}.kafka.${customer}.com,OU=Dev,O=${customer},L=${location},ST=England,C=GB" \
    -ext "SAN=dns:${user},dns:localhost,dns:127.0.0.1" \
    -keystore kafka.${user}.keystore.jks \
    -keyalg RSA \
    -storepass Passw0rd \
    -keypass Passw0rd \
    -storetype pkcs12
#
# Create the certificate signing request (CSR)
keytool -keystore kafka.${user}.keystore.jks \
    -alias ${user} \
    -certreq -file ${user}.csr \
    -storepass Passw0rd \
    -keypass Passw0rd \
    -ext "SAN=dns:${user},dns:localhost,dns:127.0.0.1"
#
# Sign the host certificate with the certificate authority (CA)
# Set a random serial number (avoid problems from using '-CAcreateserial' when parallelizing certificate generation)
CERT_SERIAL=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf("0x%.4x%.4x%.4x%.4x\n", rand()*65535 + 1, rand()*65535 + 1, rand()*65535 + 1, rand()*65535 + 1) }')
#
rm -f ${CA_PATH}/${user}-openssl-extfile.extfile
cat > ${CA_PATH}/${user}-openssl-extfile.extfile << EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
CN = ${user}
[v3_req]
extendedKeyUsage = serverAuth, clientAuth
EOF
#subjectAltName = @alt_names
#[alt_names]
#$DNS_ALT_NAMES
#EOF
#
echo "------- ${user} ------------>"
cat ${CA_PATH}/${user}-openssl-extfile.extfile
echo "<---------------------------"
#
openssl x509 -req \
    -CA ${CA_PATH}/kafka-ca.crt \
    -CAkey ${CA_PATH}/kafka-ca.key \
    -in ${user}.csr \
    -out ${user}-ca-signed.crt \
    -sha256 \
    -days 365 \
    -set_serial ${CERT_SERIAL} \
    -passin pass:Passw0rd \
    -extensions v3_req \
    -extfile ${CA_PATH}/${user}-openssl-extfile.extfile
#    
# Sign and import the CA cert into the keystore
keytool -noprompt \
    -keystore kafka.${user}.keystore.jks \
    -alias kafka-caroot \
    -import \
    -file ${CA_PATH}/kafka-ca.crt \
    -storepass Passw0rd \
    -keypass Passw0rd
#keytool -list -v -keystore kafka.$i.keystore.jks -storepass Passw0rd

# Sign and import the host certificate into the keystore
keytool -noprompt \
    -keystore kafka.${user}.keystore.jks \
    -alias ${user} \
    -import \
    -file ${user}-ca-signed.crt \
    -storepass Passw0rd \
    -keypass Passw0rd \
    -ext "SAN=dns:${user},dns:localhost,dns:127.0.0.1"
#keytool -list -v -keystore kafka.$i.keystore.jks -storepass Passw0rd

# Create truststore and import the CA cert
keytool \
    -noprompt \
    -keystore kafka.${user}.truststore.jks \
    -alias kafka-caroot \
    -import \
    -file ${CA_PATH}/kafka-ca.crt \
    -storepass Passw0rd \
    -keypass Passw0rd
echo ************************
#
echo "Passw0rd" > ${user}_sslkey_creds
echo "Passw0rd" > ${user}_keystore_creds
echo "Passw0rd" > ${user}_truststore_creds

