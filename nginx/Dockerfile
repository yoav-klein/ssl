
FROM nginx:1.21.4

RUN apt-get update
RUN apt-get install -y vim

RUN mkdir /etc/nginx/ssl

RUN sed -i '2 a listen 443 ssl;' /etc/nginx/conf.d/default.conf && \
	sed -i '3 a ssl_certificate /etc/nginx/ssl/server.cert;' /etc/nginx/conf.d/default.conf && \
	sed -i '4 a ssl_certificate_key /etc/nginx/ssl/server.key;' /etc/nginx/conf.d/default.conf

COPY server.key /etc/nginx/ssl
COPY server.cert /etc/nginx/ssl


