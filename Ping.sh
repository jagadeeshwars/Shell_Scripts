#!/bin/bash

for i in {1..100}
do
	IP=10.0.0.$i
	
	if ping -n 1 -w 1 "$IP" >/dev/null 2>&1
	then
		echo "$IP is up"
	else
		echo "$IP is down"
	fi
done
