FROM alpine:3.20
RUN apk add --no-cache bash coreutils jq cifs-utils rsync
COPY run.sh /run.sh
COPY truenas_backup.sh /usr/local/bin/truenas_backup.sh
RUN chmod +x /run.sh /usr/local/bin/truenas_backup.sh
CMD ["/run.sh"]
