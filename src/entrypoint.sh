#!/bin/bash
envsubst < /var/backend.conf.example > /usr/local/bin/backend.conf # replace config placeholders with env vars
add_ec2_ip_ranges.sh # add ec2 ip addresses to whitelist section
pdns_server --master --daemon=no --local-address=0.0.0.0 --config-dir=/etc/pdns/
