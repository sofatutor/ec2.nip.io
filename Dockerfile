FROM bitnami/minideb:latest

RUN install_packages python pdns-server pdns-backend-pipe curl jq gettext

# prepare config
ARG DOMAIN=${DOMAIN:-example.com}
ARG IP=${IP:-127.0.0.1}
ADD src/backend.conf.example .
RUN envsubst < backend.conf.example > /usr/local/bin/backend.conf
ADD src/nip.py /usr/local/bin/nip
ADD docker/pdns.conf /etc/pdns/pdns.conf

# add ec2 ip addresses to whitelist section
ADD src/add_ec2_ip_ranges.sh /usr/local/bin/
RUN add_ec2_ip_ranges.sh

EXPOSE 53/udp 53/tcp

CMD ["envsubst < backend.conf.example > /usr/local/bin/backend.conf", "&&", "pdns_server", "--master", "--daemon=no", "--local-address=0.0.0.0", "--config-dir=/etc/pdns/"]
