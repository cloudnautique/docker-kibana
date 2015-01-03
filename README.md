## Simple Docker container to run Kibana behind Nginx
--------
Builds a Docker image with a self signed cert and basic auth support for Kibana/Elastic search.

###To get up and running
This container needs to be connected to an ElasticSearch cluster. By default it looks for the cluster by resolving the name `elasticsearch` on the standard ES `port 9200`

It also requires creating and bind mounting in an htpasswd file to `/etc/nginx/conf.d/kibana.htpasswd`

For simplicity, the elasticsearch template works for development.
dockerfile/elasticsearch

```
docker run -d --name elasticsearch dockerfile/elasticsearch
```

then run:

```
docker run -d --link elasticsearch:elasticsearch -v $(pwd)/htpasswd:/etc/nginx/conf.d/kibana.htpasswd -p 80:80 -p 443:443 <kibana image name>
```


