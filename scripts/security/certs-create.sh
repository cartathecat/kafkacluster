#!/bin/sh
#
customer=$1
location=$2
#
rm -f *.crt *.csr *_creds *.jks *.srl *.key *.pem *.der *.p12 *.log
#
openssl req -new -x509 -keyout kafka-ca.key -out kafka-ca.crt -days 3650 \
    -subj '/CN=ca.kafka.${customer}.com/OU=Dev Kafka CA/O=${customer}/L=${location}/ST=England/C=GB' \
    -passin pass:Passw0rd -passout pass:Passw0rd
#
chmod 755 kafka-ca.key kafka-ca.crt
#users=(kafka-1 kafka-2 kafka-3 client schemaregistry restproxy connect connectorSA controlCenterAndKsqlDBServer ksqlDBUser appSA badapp clientListen zookeeper mds)
users=(zookeeper-1 zookeeper-2 zookeeper-3 kafka-1 kafka-2 kafka-3)

echo "Creating certificates"
## > "certs-create-$1.log" 2>&1
#ßprintf '%s\0' "${users[@]}" | xargs -0 -I{} -n1 -P15 sh -c './certs-create-per-user.sh "$1"'
printf '%s\0' "${users[@]}" | xargs -0 -I{} -n1 -P15 sh -c './certs-create-per-user.sh "${1}"  && echo "Created certificates for $1"' -- {}
echo "Creating certificates completed"