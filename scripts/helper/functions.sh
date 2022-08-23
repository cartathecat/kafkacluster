#!/bin/sh
#
help() {
    echo -i Usage
    echo -i "start.sh "
    echo "             -h [ | --help    ]              This help text"
    echo "             -s [ | --start   ]              Start a new Zookeeper and Kafka cluster in docker containers"
    echo "             -r [ | --restart ]              Restart stopped docker containers"
    echo "             -t [ | --term | --terminate ]   Remove stopped containers"
    echo "             -e [ | --end     ]              Stop running Zookeeper and Kafka docker nodes"
    echo "             -i [ | --status  ]              Show current status of continers"
}
#
## Stop the containers
#
stop_containers() {
    echo -i Stopping running containers
# Stop Kafka first
    for c in `docker ps -q -f name=kafka -f status=running`; do
        echo -i Attempting to stop kafka server with ID ${c}
        docker stop ${c}
        RC=$?
        if [ ${RC} -eq 0 ]; then
            echo -i Container ID ${c} stopped
        else
            echo -e ERROR: unable to stop ID ${c}
            return 0 ${RC} 
        fi
    done
#
    for c in `docker ps -q -f name=zookeeper -f status=running`; do
        echo -i Attempting to stop zookeeper server with ID ${c}
        docker stop ${c}
        RC=$?
        if [ ${RC} -eq 0 ]; then
            echo -i Container ID ${c} stopped
        else
            echo -e ERROR: unable to stop ID ${c}
            return ${RC} 
        fi
    done
    return 0
#
}
#
## Restart the containers
#
restarting_containers() {
    echo -i Restarting stopped containers
#
    for c in `docker ps -q -f name=zookeeper -f status=exited`; do
        echo -i Attempting to restart zookeeper server with ID ${c}
        docker start ${c}
        RC=$?
        if [ ${RC} -eq 0 ]; then
            echo -i Container ID ${c} started
        else
            echo -e ERROR: unable to start ID ${c}
            return ${RC} 
        fi
    done
#
    for c in `docker ps -q -f name=kafka -f status=exited`; do
        echo -i Attempting to start kafka server with ID ${c}
        docker start ${c}
        RC=$?
        if [ ${RC} -eq 0 ]; then
            echo -i Container ID ${c} started
        else
            echo -e ERROR: unable to start ID ${c}
            return ${RC} 
        fi
    done
    return 0
}
#
## Terminate the containers
#
terminate_containers() {
    echo -i Terminating running containers
    stop_containers
    for c in `docker ps -q -f name=kafka -f status=exited`; do
        echo -i Attempting to terminate kafka server with ID ${c}
        docker rm ${c}
        RC=$?
        if [ ${RC} -eq 0 ]; then
            echo -i Kafka Container ID ${c} has been removed
        else
            echo -e ERROR: unable to terminate ID ${c}
            return 0 ${RC} 
        fi
    done
    echo -i Kafak servers have been removed
#
    for c in `docker ps -q -f name=zookeeper -f status=exited`; do
        echo -i Attempting to terminate zookeeper server with ID ${c}
        docker rm ${c}
        RC=$?
        if [ ${RC} -eq 0 ]; then
            echo -i Zookeeper Container ID ${c} has been terminated
        else
            echo -e ERROR: unable to terminate ID ${c}
            return ${RC} 
        fi
    done
    echo -i Zookeeper servers have been removed

    return 0

}
#
## Show Zookeeper / Kafka status
#
show_status() {
    echo -i Show current status of containers
    echo -i --------------------------------------
    show_zookeeper_and_kafka_status
}
#
show_zookeeper_and_kafka_status() {
    docker ps -a -f name=zookeeper -f name=kafka
}
#
verify_install() {
    local cmd=${1}
    if [[ $(type ${cmd} 2>&1) =~ "not found" ]]; then
        echo -e "ERROR: The script requires ${cmd}.  Please install ${cmd} and run again."
        exit 1    
    fi
    return 0

}
#
## Function to ensure we have the tools installed
#
preflight_checks() {
    # Verify tools are installed
    for cmd in curl docker-compose keytool openssl xargs awk; do
        echo -i Checking ${cmd}
        verify_install ${cmd}
    done
#
# Verify docker daemon 
# Shows only the container id
    docker ps -q || exit 1
#
# verify memory
    if [[ $(docker system info --format '{{.MemTotal}}') -lt 8000000000 ]]; then
        echo -e "WARNING: Memory available to Docker should be at least 8 GB (default is 2 GB), otherwise cp-demo may not work properly."
        if [[ "$VIZ" == "true" ]]; then
            echo -e "ERROR: Cannot proceed with Docker memory less than 8 GB when 'VIZ=true' (enables Elasticsearch and Kibana).  Either increase memory available to Docker or restart cp-demo with 'VIZ=false' (see https://docs.confluent.io/platform/current/tutorials/cp-demo/docs/index.html#start)\n"
            exit 1    
        fi
    fi
#
# Verify docker CPU cores
    echo -i OS details $(uname -a)
    echo -i Number of CPUs available on OS is $(sysctl -n hw.ncpu)
    echo -i Number of CPUs available to docker is $(docker system info --format '{{.NCPU}}')
#
    if [[ $(docker system info --format '{{.NCPU}}') -lt 2 ]]; then
        echo -e "WARNING: Number of CPU cores available to Docker must be at least 2, otherwise cp-demo may not work properly."
        sleep 3
    fi

}
#
## Start new instances
#
startup_kafka() {
    echo -i Starting new Docker Zookeeper and Kafka instances
    docker-compose -f zookeeper-kafka-3.yml up --no-recreate -d zookeeper-1 zookeeper-2 zookeeper-3
#
    docker-compose -f zookeeper-kafka-3.yml up --no-recreate -d kafka-1 kafka-2 kafka-3

}