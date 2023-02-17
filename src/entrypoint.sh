#!/bin/bash
envsubst < /var/backend.conf.example > /usr/local/bin/backend.conf # replace config placeholders with env vars
add_ec2_ip_ranges.sh # add ec2 ip addresses to whitelist section
"$1" "${@:2}"
