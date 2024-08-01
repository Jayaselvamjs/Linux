mv /<repo-name> /home/user/last-backup
mkdir /<repo-name>
sudo systemctl status elasticsearch
sudo chmod -R 777 /<repo-name>
sudo chown -R elasticsearch:elasticsearch /<repo-name>
nano /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch
curl -X PUT -H "Content-Type: application/json" 'http://localhost:9200/_snapshot/<repo-name>' -d '{"type": "fs", "settings": {"location": "/<repo-path>", "compress": true}}'
curl -XGET "http://localhost:9200/_snapshot/_all?pretty"
curl -X GET 'http://localhost:9200/_cat/indices'
curl -XPUT 'http://localhost:9200/_snapshot/<repo-name>/first-snapshot?wait_for_completion=true'
curl -X GET 'http://localhost:9200/_snapshot/_all?pretty'

