FROM bitnami/minideb:latest

RUN install_packages python pdns-server pdns-backend-pipe curl jq gettext

# prepare config
ARG DOMAIN=${DOMAIN:-example.com}
ARG IP=${IP:-127.0.0.1}
ADD src/backend.conf.example /var/
ADD src/nip.py /usr/local/bin/nip
ADD docker/pdns.conf /etc/pdns/pdns.conf
ADD src/add_ec2_ip_ranges.sh /usr/local/bin/

EXPOSE 53/udp 53/tcp

COPY src/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
CMD ["pdns_server", "--master", "--daemon=no", "--local-address=0.0.0.0", "--config-dir=/etc/pdns/"]
