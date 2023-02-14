FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nginx
RUN echo 'Hello, Alexei Emelin 1.0.0' \
	>/var/www/html/index.nginx-debian.html
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
EXPOSE 80
MAINTAINER Alexei Emelin

