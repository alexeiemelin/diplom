FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nginx
RUN echo 'Hello, Alexei Emelin v0.0.2' \
	>/var/www/html/index.nginx-debian.html
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
EXPOSE 80
MAINTAINER Alexei Emelin

