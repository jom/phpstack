#!/bin/bash

################################################################
# The following should be run anytime the container is booted, #
# incase host is resized                                       #
################################################################

# Set PHP pools to take up to 1/2 of total system memory total, split between the two pools.
# 30MB per process is conservative estimate, is usually less than that
SERVER_IP_ADDRESS=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "Web Server IP Address: $SERVER_IP_ADDRESS"

if [ $TZ ]; then
  echo "Setting timezone: $TZ"
  echo $TZ > /persist/etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

PHP_MAX=$(expr $(grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//') / 1024 / 2 / 30 / 2)
sed -i -e"s/pm.max_children = 5/pm.max_children = $PHP_MAX/" /etc/php/7.0/fpm/pool.d/www.conf

# Set nginx worker processes to equal number of CPU cores
sed -i -e"s/worker_processes\s*4/worker_processes $(cat /proc/cpuinfo | grep processor | wc -l)/" /etc/nginx/nginx.conf

chmod +x /var/www/cron/*
chown -R www-data.www-data /var/www/cron