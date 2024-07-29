sudo apt-get install -f
sudo apt-get remove --purge mysql-server* mysql-client* mysql-common* mysql-server-core-* mysql-client-core-*
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get update
sudo apt-get install mysql-server-8.0 mysql-client-8.0
sudo service mysql status
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo sed -i ,/lower_case_table_names/d' /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo echo lower_case_table_names=1 | sudo tee -a  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
sudo cp -r /var/lib/mysql /var/lib/mysql_backup
sudo rm -rf /var/lib/mysql
sudo mkdir /var/lib/mysql
sudo chmod -R 755 /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo mysqld --defaults-file=/etc/mysql/my.cnf --initialize --user=mysql --lower_case_table_names=1 --console
sudo systemctl restart mysql
service mysql status
sudo grep 'temporary password' /var/log/mysql/error.log
sudo mysql -u root -p


