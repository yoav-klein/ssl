
FROM nginx

RUN apt-get update
RUN apt-get install -y vim

RUN mkdir /etc/nginx/ssl
COPY server.key /etc/nginx/ssl
COPY server.cert /etc/nginx/ssl


