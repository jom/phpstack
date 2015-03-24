FROM phusion/baseimage:0.9.16
MAINTAINER Jacob Morrison <jomorrison@gmail.com>

ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install required packages
# LANG=C.UTF-8 line is needed for ondrej/php5 repository
RUN \
	export LANG=C.UTF-8 && \
	add-apt-repository ppa:ondrej/php5-5.6 && \
	add-apt-repository -y ppa:nginx/stable && \
	apt-get update && \
	apt-get -y install nginx mysql-client php5-fpm php5-mysql php5-curl php5-mcrypt php5-cli php5-gd php5-intl php5-xsl pwgen wget unzip

# Next composer and global composer package, as their versions may change from time to time
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer.phar \
    && composer.phar global require --no-progress "fxp/composer-asset-plugin:1.0.0" \
    && composer.phar global require --no-progress "codeception/codeception=2.0.*" \
    && composer.phar global require --no-progress "codeception/specify=*" \
    && composer.phar global require --no-progress "codeception/verify=*"

RUN usermod -u 1000 www-data

# Configuration
RUN \
	sed -i -e"s/events\s{/events {\n\tuse epoll;/" /etc/nginx/nginx.conf && \
	sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2;\n\tclient_max_body_size 100m;\n\tport_in_redirect off/" /etc/nginx/nginx.conf && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 101M/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
	sed -i -e "s/;pm.max_requests\s*=\s*500/pm.max_requests = 500/g" /etc/php5/fpm/pool.d/www.conf

# nginx site conf
ADD ./conf/nginx-site.conf /etc/nginx/sites-available/default
ADD ./conf/php.ini /etc/php5/cli/conf.d/00_custom.ini
ADD ./conf/php.ini /etc/php5/fpm/conf.d/00_custom.ini

# Add runit files for each service
ADD ./services/nginx /etc/service/nginx/run
ADD ./services/php-fpm /etc/service/php-fpm/run

ADD ./shell/start.sh /etc/my_init.d/001_web.sh

# Installation helpers
ADD ./shell/composer /usr/local/bin/composer

# Execute permissions where needed
RUN \
	chmod +x /etc/service/nginx/run && \
	chmod +x /etc/service/php-fpm/run

# Data volumes
VOLUME ["/var/www", "/run"]

# Expose 8080 to the host
EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www