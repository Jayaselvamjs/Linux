sudo apt-get install openjdk-17-jre
sudo java -version
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.16/bin/apache-tomcat-10.1.16.tar.gz
sudo mkdir /opt/tomcat
sudo mkdir /opt/tomcat/server
sudo mkdir /opt/tomcat/service
sudo tar -xzvf apache-tomcat*.tar.gz -C /opt/tomcat/server --strip-components=1
sudo tar -xzvf apache-tomcat*.tar.gz -C /opt/tomcat/service --strip-components=1
sudo cp -r /home/testas/cert /opt/tomcat/server/conf 
sudo chmod 755 /opt/tomcat/server/bin/*
sudo chmod 755 /opt/tomcat/service/bin/*
sudo nano /opt/tomcat/server/conf/server.xml
sudo nano /opt/tomcat/service/conf/server.xml
sudo nano /opt/tomcat/server/conf/catalina.properties
sudo nano /opt/tomcat/service/conf/catalina.properties
sudo nano /opt/tomcat/server/conf/tomcat-users.xml 
sudo nano /opt/tomcat/service/conf/tomcat-users.xml 
sudo /opt/tomcat/service/bin/startup.sh
sudo /opt/tomcat/server/bin/startup.sh
netstat -telpen
