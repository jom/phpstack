FROM phusion/baseimage:0.9.18
MAINTAINER Jacob Morrison <jomorrison@gmail.com>

ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install required packages
# LANG=C.UTF-8 line is needed for ondrej/php5 repository
RUN \
	export LANG=C.UTF-8 && \
	apt-get update && \
	apt-get -y install redis-server

# Enable redis

# Configure redis
RUN mkdir /etc/service/redis
RUN sed -i 's/daemonize yes/daemonize no/g' /etc/redis/redis.conf
RUN sed -i 's/bind 127.0.0.1/# bind 127.0.0.1/g' /etc/redis/redis.conf

# Add runit files for each service
ADD ./services/redis /etc/service/redis/run

ADD ./shell/start.sh /etc/my_init.d/003_redis.sh

# Execute permissions where needed
RUN \
	chmod +x /etc/service/redis/run

RUN mkdir -p /persist/etc && mkdir -p /persist/bin && mv /etc/timezone /persist/etc/ && ln -s /persist/etc/timezone /etc/

ENV PATH /persist/bin:$PATH

# Data volumes
VOLUME ["/var/lib/redis", "/persist"]

EXPOSE 6379

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN usermod -u 1000 -s /bin/bash www-data

WORKDIR /var/lib/redis