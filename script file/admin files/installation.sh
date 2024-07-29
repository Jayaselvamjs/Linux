sudo apt-get update
sudo apt-get upgrade
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install ssh -y
sudo service ssh status
sudo apt-get install net-tools -y
sudo apt-get install curl -y
sudo service curl status

# PYTHON                               	[1]
sudo apt-get install python3.8
sudo apt install python3.10
python3 --version
sudo apt-get install python3.pip
python3.8 -m pip install -r requirements.txt
# DJANGO                               	[2]
sudo apt-get install python3-django
django-admin --version
# UWSGI                                	[3]
sudo apt-get install uwsgi
sudo apt-get install uwsgi-plugin-python3
uwsgi --version
# JAVA                           	[4]
sudo apt-get install openjdk-17-jdk
java --version
# NGINX					[5]
sudo apt-get install nginx
nginx -v
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx
# MYSQL					[6]
sudo apt-get install mysql-client mysql-server
mysql --version
# APACHE2				[7]
sudo apt-get install apache2* openssl*
sudo service apache2 status
# TOMCAT 10				[8]
# ELASTICSEARCH				[9]
sudo apt-get install elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl status elasticsearch
# LOGSTASH				[10]
sudo apt-get install logstash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install logstash
logstash --version
# FILEBEAT				[11]
sudo apt-get install filebeat
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install filebeat
filebeat --version


