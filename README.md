# Zookeeper and Kafka config

## Commands

### Summmary
```
export REPOSITORY=${REPOSITORY:-confluentinc}
docker-compose -f zookeeer-kafka-3.yml up -d
docker-compose -f zookeeer-kafka-3.yml down

docker exec -it kafka-1 /bin/sh

kafka-topics --bootstrap-server kafka-1:9092 --list
kafka-topics --bootstrap-server kafka-1:9093 --list --command-config /etc/config/alice.properties 

*** Users ****
kafka-configs --bootstrap-server kafka-1:9092 --describe --user bob

kafka-topics --bootstrap-server kafka-1:9092 --create --topic bob-topic --partitions 6 --replication-factor 3
kafka-topics --bootstrap-server kafka-1:9092 --create --topic alice-topic --partitions 6 --replication-factor 3

kafka-configs --bootstrap-server kafka-1:9092 --alter --add-config 'SCRAM-SHA-256=[password='Passw0rd'],SCRAM-SHA-512=[password='Passw0rd']' --entity-type users --entity-name bob

kafka-configs --bootstrap-server kafka-1:9092 --alter --add-config 'SCRAM-SHA-512=[password='Passw0rd']' --entity-type users --entity-name alice
kafka-configs --bootstrap-server kafka-1:9092 --alter --add-config 'SCRAM-SHA-512=[password='Passw0rd']' --entity-type users --entity-name bob

**** PLAINTEXT ****
kafka-console-producer --bootstrap-server kafka-1:9093 --topic alice-topic --producer.config /etc/config/alice.properties
kafka-console-consumer --bootstrap-server kafka-1:9093 --topic alice-topic --consumer.config /etc/config/alice.properties --group alice
kafka-console-consumer --bootstrap-server kafka-1:9093 --topic alice-topic --from-beginning --consumer.config /etc/config/alice.properties --group alice4

**** SASL_SCRAM ****
kafka-console-producer --bootstrap-server kafka-1:9093 --topic alice-topic --producer.config /etc/config/bob.scram.properties
kafka-console-consumer --bootstrap-server kafka-1:9093 --topic alice-topic --consumer.config /etc/config/bob.scram.properties --from-beginning --group bob


kafka-console-producer --bootstrap-server kafka-1:9093 --topic bob-topic --producer.config /etc/config/bob.properties


kafka-configs --bootstrap-server kafka-1:9092 --alter --add-config 'SCRAM-SHA-256=[iterations=8192,password=Passw0rd],SCRAM-SHA-512=[password=Passw0rd]' --entity-type users --entity-name bob

kafka-acls --bootstrap-server kafka-1:9092 --list --principle User:alice

--command-config kafka.properties --list --principal User:ickafka

```

### Jump into containers
```
docker exec -it kafka-1 /bin/sh
```

### Topics

#### List topics
```
kafka-topics --bootstrap-server kafka-1:9092 --list
```

#### Create topic
```
kafka-topics --bootstrap-server kafka-1:9092 --create --topic alice-topic --partitions 6 --replication-factor 3
```

#### Describe topic
```
kafka-topics --bootstrap-server kafka-1:9092 --describe --topic alice-topic
```
#### Output
```
Topic: alice-topic	TopicId: kO6IzZ1vQzGAJ6vVV5r8zA	PartitionCount: 6	ReplicationFactor: 3	Configs: 
	Topic: alice-topic	Partition: 0	Leader: 1	Replicas: 1,2,3	Isr: 1,2,3
	Topic: alice-topic	Partition: 1	Leader: 2	Replicas: 2,3,1	Isr: 2,3,1
	Topic: alice-topic	Partition: 2	Leader: 3	Replicas: 3,1,2	Isr: 3,1,2
	Topic: alice-topic	Partition: 3	Leader: 1	Replicas: 1,3,2	Isr: 1,3,2
	Topic: alice-topic	Partition: 4	Leader: 2	Replicas: 2,1,3	Isr: 2,1,3
	Topic: alice-topic	Partition: 5	Leader: 3	Replicas: 3,2,1	Isr: 3,2,1
```

## Users

### Create user
```
kafka-configs --bootstrap-server kafka-1:9092 --alter --add-config 'SCRAM-SHA-512=[password='Passw0rd']' --entity-type users --entity-name alice
```

### Describe user
```
kafka-configs --bootstrap-server kafka-1:9092 --describe --user alice
```

## Access Control Lists (ACL's)


## Console producer 
### Connect using PLAINTEXT ( NO SASL )
#### Producer command
```
kafka-console-producer --bootstrap-server kafka-1:9092 --topic alice-topic
```

### Connect using SASL 
#### SASL
```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="alice" password="Passw0rd";
```

#### Producer command
```
kafka-console-producer --bootstrap-server kafka-1:9093 --topic alice-topic --producer.config /etc/kafka1/alice.properties
```

## Console consumer 
### Connect using PLAINTEXT ( NO SASL )
```
kafka-console-consumer --bootstrap-server kafka-1:9092 --topic alice-topic --from-beginning --group alice
```


## Zookeeper

### zookeeper_jaas.conf

```
Server {
       org.apache.zookeeper.server.plain.PLainLoginModule required
       username="admin"
       password="admimn-secret"
       user_admin="admin-secret"
       user_xxxxxxxx="xxxxxxxx";
};
```

### Zookeeper yml

```
services:
    zookeeper-1: 
        image: ${REPOSITORY}/cp-zookeeper:latest
        container_name: zookeeper-1
        ports:
          - 22181:2181
        environment:
          ZOOKEEPER_SERVER_ID: 1
          ZOOKEEPER_CLIENT_PORT: 2181
          ZOOKEEPER_TICK_TIME: 2000
          ZOOKEEPER_SERVERS: zookeeper-1:2888:3888;zookeeper-2:2888:3888;zookeeper-3:2888:3888
#    
          ZOOKEEPER_SASL_ENABLED : 'false'
#          ZOOKEEPER_AUTH_PROVIDER_SASL: org.apache.zookeeper.server.auth.SASLAuthenticationProvider
        volumes:
          - ./config/zookeeper_jaas.conf:/etc/kafka/zookeeper_jaas.conf
```

## Kafka

### kafka_server_jaas.yml

```
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
      username="admin"
      password="admin-secret"
      user_admin="admin-secret"
      user_xxxxxxxx="xxxxxxxx";
};
```

### Monitoring for Prometheus

```
rules:
- pattern: ".*"
```

### Kafka yml

```
    kafka-1:
        image: ${REPOSITORY}/cp-enterprise-kafka:latest
        container_name: kafka-1
        ports:
#          - 9092
#          - 9093
          - 29092:9092
          - 29093:9093
          - 29094:9094
          - 29010:9010
        depends_on:
          - zookeeper-1
          - zookeeper-2
          - zookeeper-3
        environment:
          KAFKA_BROKER_ID: 1
          KAFKA_ZOOKEEPER_CONNECT: zookeeper-1:2181,zookeeper-2:2181,zookeeper-3:2181
          KAFKA_ZOOKEEPER_SSL_CLIENT_ENABLE: 'false'
          #
          KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: SASL_PLAINTEXT:SASL_PLAINTEXT,PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT,EXTERNAL_SASL_PLAINTEXT:SASL_PLAINTEXT
          KAFKA_LISTENERS: PLAINTEXT://kafka-1:9092,SASL_PLAINTEXT://kafka-1:9093,EXTERNAL_SASL_PLAINTEXT://kafka-1:9094
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-1:9092,SASL_PLAINTEXT://kafka-1:9093,EXTERNAL_SASL_PLAINTEXT://127.0.0.1:29094
          KAFKA_INTERNAL_BROKER_LISTENER_NAME: SASL_PLAINTEXT
          #
          KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: PLAIN
          KAFKA_SASL_ENABLED_MECHANISMS: PLAIN
          KAFKA_SUPER_USERS: User:admin
          KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND: 'true'
          #
          #KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer
          #
          #KAFKA_JMX_PORT: 9991
          EXTRA_ARGS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false \
          -Dcom.sun.management.jmxremote.ssl=false -Djava.util.logging.config.file=logging.properties \
          -javaagent:/usr/share/jmx_exporter/jmx_prometheus_javaagent-0.17.0.jar=9010:/usr/share/jmx_exporter/config.yml"

          #EXTRA_ARGS: "-javaagent:/usr/share/jmx_exporter/jmx_prometheus_javaagent-0.17.0.jar=9010:/usr/share/jmx_exporter/kafka-broker.yaml" 
          #
          ZOOKEEPER_SASL_ENABLED : 'false'
          KAFKA_OPTS: "-Djava.security.auth.login.config=/etc/kafka1/kafka_server_jaas.conf"
        volumes:
         - ./config/:/etc/kafka1/
         - ./monitoring/:/usr/share/jmx_exporter/
```
