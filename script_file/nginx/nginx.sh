sudo apt-get update
sudo apt-get install nginx
nginx –version
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo cp ./nginx_reptsrv /etc/nginx/sites-available/default
sudo service nginx restart
