#!/bin/bash
## Install Apache Kafka on Ubuntu
## Step 1 — Creating a User for Kafka
sudo adduser kafka
sudo adduser kafka sudo
su -l kafka

## Step 2 — Downloading and Extracting the Kafka Binaries

mkdir ~/Downloads
curl "https://downloads.apache.org/kafka/2.8.2/kafka_2.13-2.8.2.tgz" -o ~/Downloads/kafka.tgz
mkdir ~/kafka && cd ~/kafka 
tar -xvzf ~/Downloads/kafka.tgz --strip 1

## Step 3 — Configuring the Kafka Server
sudo tee -i ~/kafka/config/server.properties <<EOF
delete.topic.enable = true   -----------Add the line to the bottom of the file
EOF
sudo sed -i 's/log.dirs=.*/log.dirs=/home/kafka/logs/g' ~/kafka/config/server.properties			

## Step 4 — Creating systemd Unit Files and Starting the Kafka Server
sudo tee -i /etc/systemd/system/zookeeper.service <<EOT
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOT

sudo tee -i /etc/systemd/system/kafka.service <<EOT
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /home/kafka/kafka/kafka.log 2>&1'
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOT

sudo apt update
#sudo apt install default-jdk
wget https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.deb
dpkg -i jdk-17.0.10_linux-x64_bin.deb
java --version

sudo systemctl daemon-reload
sudo systemctl start zookeeper
sudo systemctl status zookeeper
sudo journalctl -u zookeeper

sudo systemctl start kafka
sudo systemctl status kafka
 
sudo systemctl enable zookeeper
sudo systemctl enable kafka

## Step 5 — Testing the Kafka Installation
# Publishing messages in Kafka requires:
#   A producer, who enables the publication of records and data to topics.
#   A consumer, who reads messages and data from topics.

~/kafka/bin/kafka-topics.sh --create --zookeeper localhost:9092 --replication-factor 1 --partitions 1 --topic TutorialTopic

#Output
#Created topic TutorialTopic.

echo "Hello, World" | ~/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic TutorialTopic > /dev/null

~/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic TutorialTopic --from-beginning

#Output
#Hello, World

su -l kafka
echo "Hello World from Sammy at DigitalOcean!" | ~/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic TutorialTopic > /dev/null

#Output
#Hello, World
#Hello World from Sammy at DigitalOcean!

## Step 6 — Hardening the Kafka Server
# Remove the kafka user from the sudo group:
sudo deluser kafka sudo

sudo passwd kafka -l
sudo su - kafka
sudo passwd kafka -u

## Step 7 — Installing KafkaT (Optional)
sudo apt install ruby ruby-dev build-essential

sudo CFLAGS=-Wno-error=format-overflow gem install kafkat
#Output
#...
#Done installing documentation for json, colored, retryable, highline, trollop, zookeeper, zk, kafkat after 3 seconds
#8 gems installed

sudo tee -i ~/.kafkatcfg <<EOT 
{
  "kafka_path": "~/kafka",
  "log_path": "/home/kafka/logs",
  "zk_path": "localhost:9092"
}
EOT


kafkat partitions\
#Output
#[DEPRECATION] The trollop gem has been renamed to optimist and will no longer be supported. Please switch to optimist as soon as possible.
#/var/lib/gems/2.7.0/gems/json-1.8.6/lib/json/common.rb:155: warning: Using the last argument as keyword parameters is deprecated
#...
#Topic                 Partition   Leader      Replicas        ISRs
#TutorialTopic         0             0         [0]             [0]
#__consumer_offsets	  0		          0		      [0]							[0]
#...
#...


### https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04