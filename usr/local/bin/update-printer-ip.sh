#!/bin/bash
IP=$(avahi-resolve-host-name -4 matthews-Mac-mini.local 2>/dev/null | awk '{print $2}')
if [ ! -z "$IP" ]; then
	sed -i '/matthews-Mac-mini.local/d' /etc/hosts
	echo "$IP matthews-Mac-mini.local" >> /etc/hosts
fi
