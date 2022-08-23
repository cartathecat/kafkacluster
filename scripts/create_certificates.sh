#!/bin/sh
#
# Create certificates
#
#
set +e 
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
#
source ${DIR}/env.sh
#
echo -i "Generate keys and certificates used for SSL (see ${DIR}/security)"
#
echo -i REPOSITORY          : ${REPOSITORY}
echo -i USER                : ${USER}
echo -1 CONFLUENT_DOCKER_TAG: ${CONFLUENT_DOCKER_TAG}
#
docker run -v ${DIR}/security/:/etc/kafka/secrets/ -u0 ${REPOSITORY}/cp-server:${CONFLUENT_DOCKER_TAG} \
    bash -c "yum -y install findutils; cd /etc/kafka/secrets; ./certs-create.sh && chown -R $(id -u ${USER}):$(id -g ${USER}) /etc/kafka/secrets"
#cd /etc/kafka/secrets && ./certs-create.sh && chown -R $(id -u ${USER}):$(id -g ${USER}) /etc/kafka/secrets"
