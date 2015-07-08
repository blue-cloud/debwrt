#!/bin/sh
#
# Minimal firewal script 
#
# Amain <amain@debwrt.net>

. /lib/lsb/init-functions

IPT=/sbin/iptables

flush() {
    $IPT -t filter -F
    $IPT -t filter -X
    $IPT -t nat    -F
    $IPT -t nat    -X
}

start() {
    flush

    $IPT -t filter -A INPUT       -m state --state RELATED,ESTABLISHED -i wan -j ACCEPT
    $IPT -t filter -A INPUT       -i wan -j DROP

    $IPT -t filter -A FORWARD     -m state --state RELATED,ESTABLISHED -i wan -j ACCEPT
    $IPT -t filter -A FORWARD     -i wan -j DROP

    #$IPT -t nat    -A POSTROUTING -o wan -j SNAT --to-source "replace: WAN-IF-IP"
    $IPT -t nat    -A POSTROUTING -o wan -j MASQUERADE

    log_action_end_msg 0
}

stop() {
	flush
	log_action_end_msg 0
}

case $1 in
	start)
  		log_action_begin_msg 'Loading firewall - starting'
		start
	;;
	stop)
  		log_action_begin_msg 'Loading firewall - stopping'
		stop
	;;
	*)
		echo "usage: `basename $0` start|stop"
	;;
esac
