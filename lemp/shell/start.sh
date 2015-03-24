#!/bin/bash


if [ ! -f /mysql-configured ]; then
  touch /mysql-configured
  
  if [ ! -f /var/lib/mysql/ibdata1 ]; then
    mysql_install_db
  fi

  # Start MySQL and wait for it to become available
  /usr/bin/mysqld_safe > /dev/null 2>&1 &

  RET=1
  while [[ $RET -ne 0 ]]; do
      echo "=> Waiting for confirmation of MySQL service startup"
      sleep 2
      mysql -uroot -e "status" > /dev/null 2>&1
      RET=$?
  done

  # Generate Koken database and user credentials
  echo "=> Generating database and credentials"
  DB_NAME=${DB_NAME:-project}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-root}

  mysqladmin -u root password $MYSQL_PASSWORD
  mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE \`$DB_NAME\`;"

  mysqladmin -uroot -p$MYSQL_PASSWORD shutdown
fi

################################################################
# The following should be run anytime the container is booted, #
# incase host is resized                                       #
################################################################

# Set PHP pools to take up to 1/2 of total system memory total, split between the two pools.
# 30MB per process is conservative estimate, is usually less than that
PHP_MAX=$(expr $(grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//') / 1024 / 2 / 30 / 2)
sed -i -e"s/pm.max_children = 5/pm.max_children = $PHP_MAX/" /etc/php5/fpm/pool.d/www.conf
sed -i -e"s/pm.max_children = 5/pm.max_children = $PHP_MAX/" /etc/php5/fpm/pool.d/images.conf

# Set nginx worker processes to equal number of CPU cores
sed -i -e"s/worker_processes\s*4/worker_processes $(cat /proc/cpuinfo | grep processor | wc -l)/" /etc/nginx/nginx.conf
