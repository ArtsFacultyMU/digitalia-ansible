#!/bin/bash

LOGFILE="/var/log/apache2/islandora-access.log"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <minutes>"
    exit 1
fi

MINUTES=$1
CUTOFF_EPOCH=$(date -d "-$MINUTES minutes" +%s)

awk -v cutoff="$CUTOFF_EPOCH" '
function parse_time(s,  d, t) {
    # Convert Apache log time format: [12/Jun/2025:15:45:02 +0000]
    split(s, d, "/")
    split(d[3], t, ":")
    month["Jan"]=1; month["Feb"]=2; month["Mar"]=3; month["Apr"]=4;
    month["May"]=5; month["Jun"]=6; month["Jul"]=7; month["Aug"]=8;
    month["Sep"]=9; month["Oct"]=10; month["Nov"]=11; month["Dec"]=12;
    return mktime(t[1] " " month[d[2]] " " d[1] " " t[2] " " t[3] " " t[4])
}

{
    ip = $1
    match($0, /\[([0-9]{2}\/[A-Za-z]+\/[0-9]{4}:[^ ]+)/, m)
    if (m[1]) {
        ts_epoch = parse_time(m[1])
        if (ts_epoch >= cutoff) {
            count[ip]++
            total++
        }
    }
}
END {
    for (ip in count)
        print ip, count[ip]
    print "TOTAL", total
}
' "$LOGFILE" | sort -k2 -n
