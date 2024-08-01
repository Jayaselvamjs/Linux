###Install and Secure the Mosquitto MQTT Messaging Broker
# Step 1 — Installing Mosquitto
sudo apt-get install mosquitto mosquitto-clients

# -h is used to specify the hostname of the MQTT server, and -t is the topic name. 
mosquitto_sub -h localhost -t test
# You’ll see no output after hitting ENTER because mosquitto_sub is waiting for messages to arrive. 
# Switch back to your other terminal and publish a message:

mosquitto_pub -h localhost -t test -m "hello world"

## Step 2 — Installing Certbot for Let’s Encrypt Certificates
sudo add-apt-repository ppa:certbot/certbot
sudo rm /etc/apt/sources.list.d/certbot-ubuntu-certbot-jammy.list
sudo apt-get update
sudo apt-get install certbot

## Step 3 — Running Certbot
sudo ufw allow http
sudo certbot certonly --standalone --standalone-supported-challenges http-01 -d mqtt.example.com

## Step 4 — Setting up Certbot Automatic Renewals
sudo sed -i -e '$a15 3 * * * certbot renew --noninteractive --post-hook "systemctl restart mosquitto"' /etc/crontab

## Step 5 — Configuring MQTT Passwords
sudo mosquitto_passwd -c /etc/mosquitto/passwd sammy
sudo tee -i /etc/mosquitto/conf.d/default.conf <<EOT
allow_anonymous false
password_file /etc/mosquitto/passwd
EOT

sudo systemctl restart mosquitto
# Try to publish a message without a password
mosquitto_pub -h localhost -t "test" -m "hello world"
# Output
# Connection Refused: not authorised.
# Error: The connection was refused.

mosquitto_sub -h localhost -t test -u "sammy" -P "password"
mosquitto_pub -h localhost -t "test" -m "hello world" -u "sammy" -P "password"

## Step 6 — Configuring MQTT SSL
sudo tee -i /etc/mosquitto/conf.d/default.conf <<EOF
listener 1883 localhost

listener 8883
certfile /etc/letsencrypt/live/mqtt.example.com/cert.pem
cafile /etc/letsencrypt/live/mqtt.example.com/chain.pem
keyfile /etc/letsencrypt/live/mqtt.example.com/privkey.pem
EOF

sudo systemctl restart mosquitto
sudo ufw allow 8883
# Now we test again using mosquitto_pub, with a few different options for SSL
mosquitto_pub -h mqtt.example.com -t test -m "hello again" -p 8883 --capath /etc/ssl/certs/ -u "sammy" -P "password" 

## Step 7 — Configuring MQTT Over Websockets (Optional)
sudo tee -i /etc/mosquitto/conf.d/default.conf <<EOF
listener 8083
protocol websockets
certfile /etc/letsencrypt/live/mqtt.example.com/cert.pem
cafile /etc/letsencrypt/live/mqtt.example.com/chain.pem
keyfile /etc/letsencrypt/live/mqtt.example.com/privkey.pem
EOF

sudo systemctl restart mosquitto
sudo ufw allow 8083 

### https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-ubuntu-16-04