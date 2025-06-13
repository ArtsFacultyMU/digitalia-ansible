#!/bin/bash

awk '{
    ip = $1
    count[ip]++
    total++
}
END {
    for (ip in count)
        print ip, count[ip]
    print "TOTAL", total
}' /var/log/apache2/islandora-access.log | sort -k2 -n

