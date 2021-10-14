FROM bitnami/minideb:latest

RUN install_packages python pdns-server pdns-backend-pipe curl jq
ADD src/backend.conf.example /usr/local/bin/backend.conf
ADD src/nip.py /usr/local/bin/nip
ADD src/add_ec2_ip_ranges.sh /usr/local/bin/
ADD docker/pdns.conf /etc/pdns/pdns.conf
RUN add_ec2_ip_ranges.sh

EXPOSE 53/udp 53/tcp
CMD ["pdns_server", "--master", "--daemon=no", "--local-address=0.0.0.0", "--config-dir=/etc/pdns/"]
