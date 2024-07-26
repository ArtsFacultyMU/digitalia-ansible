#!/bin/bash

ISLANDORA_SERVERS_LIST=/home/krejvl/ansible/digitalia-ansible/inventory/02-phil
LOGSDIR=/home/krejvl/logs
RUSER=islandora
EMAILS='krejcir@ics.muni.cz, strakosova@phil.muni.cz, 469190@mail.muni.cz, brejchova@phil.muni.cz'

RED_BOLD="\033[1;31m"
GREEN_BOLD="\033[1;32m"
RED="\033[0;31m"
GREEN="\033[0;32m"
DARK_GRAY="\033[1;30m"
RESET="\033[0m"

mail=${2:-"no"}

if [ $# -lt 1 ];
then
	echo "security_check_overview.sh check"
	echo "Send an overview email on pending security updates on modules"
	exit 0
fi

lastlogfile=${LOGSDIR}/islandora_security_report.html
logfile=${lastlogfile}-$(date --iso-8601=seconds)

echo "<h2>" > $lastlogfile
echo "Islandora security report" | tee -a $lastlogfile
echo "</h2>" >> $lastlogfile

echo "<div style='font-size: .5rem'>" >> $lastlogfile
echo "<div style='font-style: italic'>" >> $lastlogfile
echo "[server name] [no_of_sec_issues] ([packges_affected])" | tee -a $lastlogfile
echo "</div>" >> $lastlogfile

while read line 
do
	echo $line | grep -q 'phil_ubuntu_test'
	if [ $? -eq 0 ]; then break; fi

	echo $line | grep -q 'phil\.muni\.cz'

	if [ $? -eq 0 ]
	then
		server_name=`echo $line | sed 's/\(^[^ ]*\).*/\1/'`
		res=`ssh -n ${RUSER}@${server_name} /home/islandora/bin/islandora_security_report.sh 2>&1 | grep -iv 'abandoned'`

		echo "$res" | grep -q 'Composer could not'

		if [ $? -eq 0 ]
		then
			 echo -e "${DARK_GRAY}${server_name} no audit support${RESET}"
			 echo "<div><span style='color: gray'>${server_name} no audit support</span></div>" >> $lastlogfile
			 continue
		fi

		echo "$res" | grep -q 'package'

		if [ $? -eq 0 ]
		then
			num=`echo "$res" | grep 'package' | sed 's/Found \([0-9]\+\).*/\1/'`
			pack=`echo "$res" | grep 'package' | sed 's/Found [0-9]\+.*\([0-9]\+\).*/\1/'`
			echo -e "${RED_BOLD}${server_name}${RESET} ${RED}${num} (${pack})${RESET}"
			echo "<div><span style='color: red; font-weight: bold'>${server_name}</span> <span style='color: red;'>${num} (${pack})</span></div>" >> $lastlogfile
		else
			echo -e "${GREEN}${server_name}${RESET}"
			echo "<div><span style='color: green;'>${server_name}</span></div>" >> $lastlogfile
		fi
	fi
done < ${ISLANDORA_SERVERS_LIST}

echo "<div style='margin-top: 1rem'>For details log on the affected server above as <span style='font-style: italic'>islandora</span> user and run</div>" >> $lastlogfile
echo "<div style='font-family: monospace; margin-top: .5rem'>/home/islandora/bin/islandora_security_report.sh table</div>" >> $lastlogfile
echo "</div>" >> $lastlogfile

if [ $mail != 'no' ]
then
	cat $lastlogfile | mutt -s "Islandora security report" -e 'set from=root@sebulba.ics.muni.cz' -e 'set content_type=text/html' -- "$EMAILS" 
fi

cp $lastlogfile $logfile
