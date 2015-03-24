FROM phusion/baseimage:0.9.16
MAINTAINER Jacob Morrison <jomorrison@gmail.com>

ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install required packages
# LANG=C.UTF-8 line is needed for ondrej/php5 repository
RUN \
	export LANG=C.UTF-8 && \
	apt-get update && \
	apt-get -y install mysql-server mysql-client pwgen wget

# Configuration
RUN sed -i -e "s/bind-address\s*=/\# bind-address\s*=/g" /etc/mysql/my.cnf

ADD ./services/mysql /etc/service/mysql/run

ADD ./shell/start.sh /etc/my_init.d/002_mysql.sh

# Execute permissions where needed
RUN chmod +x /etc/service/mysql/run

# Data volumes
VOLUME ["/var/lib/mysql"]

EXPOSE 3360

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/lib/mysql