# DELETE
curl -XDELETE 'http://localhost:9200/_all'
# RESTORE
curl -XGET 'http://localhost:9200/_snapshot/elasticsearch-backup/first-snapshot/_restore?wait_for_completion=true'
