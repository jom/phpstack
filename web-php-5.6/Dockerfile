FROM phusion/baseimage:0.9.18
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
	apt-get -y install libssl-dev libcurl4-openssl-dev nginx mysql-client git nano gcc libevent-dev libpcre3-dev php5-dev php-pear php5-fpm php5-mysql php5-ldap php5-curl php5-mcrypt php5-cli php5-xcache php5-gd php5-intl php5-xsl pwgen wget unzip && \
	yes '' | pecl install libevent-0.1.0 && \
	yes '' | pecl install mongodb

RUN usermod -u 1000 -s /bin/bash www-data

# Configuration
RUN \
	sed -i -e"s/events\s{/events {\n\tuse epoll;/" /etc/nginx/nginx.conf && \
	sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2;\n\tclient_max_body_size 100m;\n\tport_in_redirect off/" /etc/nginx/nginx.conf && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 101M/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
	sed -i -e "s/;pm.max_requests\s*=\s*500/pm.max_requests = 500/g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s/;clear_env\s*=\s*no/clear_env = no/g" /etc/php5/fpm/pool.d/www.conf

# nginx site conf
ADD ./conf/nginx-site.conf /etc/nginx/sites-available/default
ADD ./conf/php.ini /etc/php5/cli/conf.d/00_custom.ini
ADD ./conf/php.ini /etc/php5/fpm/conf.d/00_custom.ini

# Add runit files for each service
ADD ./services/nginx /etc/service/nginx/run
ADD ./services/php-fpm /etc/service/php-fpm/run
ADD ./services/custom-service /etc/service/custom-service/run

ADD ./shell/start.sh /etc/my_init.d/001_web.sh

# Installation helpers
ADD ./shell/composer /usr/local/bin/composer
ADD ./shell/composer-setup /usr/local/bin/composer-setup


# Execute permissions where needed
RUN \
	chmod +x /etc/service/nginx/run && \
	chmod +x /etc/service/php-fpm/run && \
	chmod +x /etc/service/custom-service/run && \
	chmod +x /usr/local/bin/composer && \
	chmod +x /usr/local/bin/composer-setup

RUN mkdir -p /persist/etc && mkdir -p /persist/bin && mv /etc/timezone /persist/etc/ && ln -s /persist/etc/timezone /etc/

ENV PATH /persist/bin:$PATH

# Data volumes
VOLUME ["/var/www", "/var/www/cron", "/persist"]

# Expose 80 to the host
EXPOSE 80

COPY ./cron/* /var/www/cron/

RUN \ 
	(crontab -l ; echo "10 * * * * sudo -u www-data /var/www/cron/hourly.cron.sh") | sort - | uniq - | crontab - && \
	(crontab -l ; echo "0 0 * * * sudo -u www-data /var/www/cron/midnight.cron.sh") | sort - | uniq - | crontab - && \
	(crontab -l ; echo "0 19 * * * sudo -u www-data /var/www/cron/evening.cron.sh") | sort - | uniq - | crontab - && \
	(crontab -l ; echo "0 4 * * * sudo -u www-data /var/www/cron/morning.cron.sh") | sort - | uniq - | crontab - && \
	(crontab -l ; echo "0 1 * * 0 sudo -u www-data /var/www/cron/weekly.cron.sh") | sort - | uniq - | crontab - && \
	(crontab -l ; echo "0 2 1 * * sudo -u www-data /var/www/cron/monthly.cron.sh") | sort - | uniq - | crontab -

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www
