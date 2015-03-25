#!/bin/bash

SERVER_IP_ADDRESS=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "Redis Server IP Address: $SERVER_IP_ADDRESS"