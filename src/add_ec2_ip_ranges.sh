#!/usr/bin/env bash

ip_ranges=($(curl -sk https://ip-ranges.amazonaws.com/ip-ranges.json | jq -c '.prefixes[] | select(.region=="eu-central-1" and .ip_prefix and .service == "EC2") | .ip_prefix'))
whitelist=$(for i in "${!ip_ranges[@]}"; do echo "ec2_eu_central_1_$i = ${ip_ranges[$i]}"; done | sed 's/"//g')

if [ -f /usr/local/bin/backend.conf ]; then
  echo "$whitelist" >> /usr/local/bin/backend.conf
else
  echo "$whitelist"
fi
