cp -r /jlog /home/ubuntu/oldlog
rm -rf /jlog
sleep 5
mkdir /jlog
sudo systemctl status elasticsearch
sudo chmod -R 777 /jlog
sudo chown -R elasticsearch:elasticsearch /jlog
#nano /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch
sudo systemctl status elasticsearch

curl -X PUT -H "Content-Type: application/json" 'http://localhost:9200/_snapshot/jslog' -d '{"type": "fs", "settings": {"location": "/jlog", "compress": true}}'

sleep 5

curl -XPUT 'http://localhost:9200/_snapshot/jslog/first-snapshot?wait_for_completion=true'


