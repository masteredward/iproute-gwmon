#!/bin/bash

PRIMARY_GW=192.168.0.1
FAILOVER_GW=192.168.1.1
MONITOR_IP=192.36.148.17 # i.root-servers.net
PING_COUNT=10
MAX_PING_LOSS=4

# Test gateways
ip route add $MONITOR_IP via $PRIMARY_GW metric 50
PGW_TEST=`ping $MONITOR_IP -c $PING_COUNT | grep 'packet loss' | awk '{print $6}' | tr -d '%'`
ip route change $MONITOR_IP via $FAILOVER_GW metric 50
FGW_TEST=`ping $MONITOR_IP -c $PING_COUNT | grep 'packet loss' | awk '{print $6}' | tr -d '%'`
ip route del $MONITOR_IP

if test $PGW_TEST -gt $MAX_PING_LOSS && test $FGW_TEST -le $MAX_PING_LOSS
then
	if test "`ip route | grep default | awk '{print $3}'`" != "$FAILOVER_GW"
	then
		ip route replace default via $FAILOVER_GW metric 100
		echo `date | tr -d '\n' && echo " - Alternado Gateway para $FAILOVER_GW"` >> gwmon.log
	fi
elif test $PGW_TEST -le $MAX_PING_LOSS && test $FGW_TEST -gt $MAX_PING_LOSS
then
	if test "`ip route | grep default | awk '{print $3}'`" != "$PRIMARY_GW"
	then
		ip route replace default via $PRIMARY_GW metric 100
		echo `date | tr -d '\n' && echo " - Alternado Gateway para $PRIMARY_GW"` >> gwmon.log
	fi
else
	if test "`ip route | grep default | awk '{print $3}'`" != "$PRIMARY_GW"
	then
		ip route replace default via $PRIMARY_GW metric 100
		echo `date | tr -d '\n' && echo " - Alternado Gateway para $PRIMARY_GW"` >> gwmon.log
	fi
	
fi
