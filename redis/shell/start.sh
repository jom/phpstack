#!/bin/bash

SERVER_IP_ADDRESS=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "Server IP Address: $SERVER_IP_ADDRESS\n\n"