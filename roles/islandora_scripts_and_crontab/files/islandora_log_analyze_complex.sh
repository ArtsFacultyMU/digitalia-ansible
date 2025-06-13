#!/bin/bash

awk '{
    ip = $1
    match($0, /\[([0-9]{2}\/[A-Za-z]+\/[0-9]{4}:[^ ]+)/, m)
    if (m[1]) {
        ts = m[1]
        count[ip]++
        if (!(ip in first) || ts < first[ip]) first[ip] = ts
        if (!(ip in last) || ts > last[ip]) last[ip] = ts
        total_count++
        if (!min_ts || ts < min_ts) min_ts = ts
        if (!max_ts || ts > max_ts) max_ts = ts
    }
} END {
    for (ip in count) {
        printf "%s %d %s %s\n", ip, count[ip], first[ip], last[ip]
    }
    printf "TOTAL %d %s %s\n", total_count, min_ts, max_ts
}' /var/log/apache2/islandora-access.log | sort -k2 -n
