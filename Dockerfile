FROM nginx:latest

MAINTAINER Bill Maxwell '<bill@rancher.com>'

RUN apt-get update && apt-get install -y apache2-utils wget ca-certificates openssl

RUN mkdir /etc/nginx/ssl && cd /etc/nginx/ssl && \
    export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-zA-Z0-9 | head -c 128) && \
    export subj=$(echo "\
    /C=US \
    /ST=AZ \ 
    /O=myco \
    /localityName=Mytown \
    /commonName=MyCERT \
    /organizationalUnitName=dept \
    /emailAddress=info@bitbucket.com \
    "| tr -d ' ') && \
    openssl genrsa -out server.key -passout env:PASSPHRASE 2048 && \
    openssl req -new -subj "$(echo -n $subj)" -key server.key -out server.csr && \
    cp server.key server.key.org && \
    openssl rsa -in server.key.org -out server.key -passin env:PASSPHRASE && \
    openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt

RUN mkdir /www

WORKDIR /www
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
RUN tar -zxvf kibana-3.1.2.tar.gz
RUN chown -R www-data:www-data /www
RUN sed -i 's/\":9200\",$/\":443\",/' /www/kibana-3.1.2/config.js
RUN sed -i 's/elasticsearch:\ \"http:\/\/\"/elasticsearch:\ \"https:\/\/\"/' /www/kibana-3.1.2/config.js

ADD nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
