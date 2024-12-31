FROM alpine:3.16
RUN apk add --no-cache bash curl tar gzip mc kubectl
WORKDIR /app
COPY scripts/backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh
CMD ["/app/backup.sh"]
