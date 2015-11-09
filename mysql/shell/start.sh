#!/bin/bash

SERVER_IP_ADDRESS=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "MySQL Server IP Address: $SERVER_IP_ADDRESS"

if [ $TZ ]; then
  echo "Setting timezone: $TZ"
  echo $TZ > /config/etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi


if [ ! -f /var/lib/mysql/mysql-configured ]; then
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

  touch /var/lib/mysql/mysql-configured
fi
