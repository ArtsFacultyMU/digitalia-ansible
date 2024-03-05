#!/bin/bash

LOGS_DIR={{ root_logs_dir }}

function running() {
	running=`ps ax | grep $2 | grep $3`

	#TODO count restarts for service $1

	if [ -z "$running" ]
	then
		return 1
	else
		return 0
	fi
}

function sendinfomail() {

	echo "$HOSTNAME: $service restarted" | mutt -s "$HOSTNAME: $service restarted" root
}


datetime=`date +%Y-%m-%d-%H:%M:%S`

service='activemq'
if ! running $service java activemq.jar;
then
	chown activemq:activemq /opt/activemq/data/kahadb/*
	systemctl restart $service
	echo "$datetime ActiveMQ restarted" >> $LOGS_DIR/activemq_restart.log
	sendinfomail $service
fi

service='solr'
if ! running $service java solr;
then
	systemctl restart $service
	echo "$datetime SOLR restarted" >> $LOGS_DIR/solr_restart.log
	sendinfomail $service
fi
