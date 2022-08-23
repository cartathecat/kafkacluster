#!/bin/sh
#
set +x
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
echo DIR ${DIR}
source ${DIR}/helper/functions.sh
#
source ${DIR}/env.sh
#
#-------------------------------------------------------------------------------
#
# Which option ?
POSITIONAL_ARGS=()
if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
        case $1 in
        -s|--start)
            echo -i Starting Zookeeper and Kafka containers
            # Do preflight checks
            preflight_checks || exit
            startup_kafka
            #
            shift
            ;;
        -r|--restart)
            echo -i Restarting Zookeeper and Kafka containers
            # Do preflight checks
            restarting_containers || exit
            #
            shift
            ;;
        -e|--stop)
            echo -i Stopping running containers
            #
            stop_containers || exit
            shift
            exit 0
            ;;
        -t|--term|--terminate)
            echo -i Terminating running containers
            #
            terminate_containers || exit
            shift
            exit 0
            ;;
        -i|--status)
            echo -i Current container status
            show_status
            exit 0
            ;;
        -h|--help)
            help
            exit 0
            ;;
        -*|--*)
            echo -w "Unknown argument ${1}"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=($1)
            shift
            ;;
        esac
    done
else
    echo -e "Invalid arguments"
    help
    exit 1
fi
# Stop existing Docker containers
##${DIR}/stop.sh

##CLEAN=${CLEAN:-false}

# Build Kafka Connect image with connector plugins
#build_connect_image

# Set the CLEAN variable to true if cert doesn't exist
#if ! [[ -f "${DIR}/security/controlCenterAndKsqlDBServer-ca1-signed.crt" ]] || ! check_num_certs; then
#  echo "INFO: Running with CLEAN=true because instructed or certificates don't yet exist."
#  clean_demo_env
#  CLEAN=true
#fi

#echo
#echo "Environment parameters"
#echo "  REPOSITORY=$REPOSITORY"
#echo "  CONNECTOR_VERSION=$CONNECTOR_VERSION"
#echo "  CLEAN=$CLEAN"
#echo "  VIZ=$VIZ"
#echo "  C3_KSQLDB_HTTPS=$C3_KSQLDB_HTTPS"
#echo
#echo "  CONFLUENT_DOCKER_TAG=${CONFLUENT_DOCKER_TAG}"


#if [[ "$CLEAN" == "true" ]] ; then
#  create_certificates || exit 1
#  if [[ ! check_num_certs ]]; then
#    echo -e "\nERROR: Expected ~147 trusted certificates on the Kafka Connect server but got 1. Please troubleshoot and try again."
#    exit 1
#  fi
#fi

# Bring up zookepper cluster
##docker-compose -f zookeeper-kafka-3.yml up --no-recreate -d zookeeper-1 zookeeper-2 zookeeper-3

# Bring up kafka cluster
##docker-compose -f zookeeper-kafka-3.yml up --no-recreate -d kafka-1 kafka-2 kafka-3
#
#
#kafka-producer-perf-test --producer.config /etc/kafka1/producer.mjm.properties \
#     --throughput 200 --record-size 1000 --num-records 3000 --topic moriam03-test-3 \
#     --producer-props bootstrap.servers=kafka-1:9093 linger.ms=1500 batch.size=16384 \
#     --print-metrics | grep \
#"3000 records sent\|\
#producer-metrics:outgoing-byte-rate\|\
#producer-metrics:bufferpool-wait-ratio\|\
#producer-metrics:record-queue-time-avg\|\
#producer-metrics:request-latency-avg\|\
#producer-metrics:batch-size-avg"

