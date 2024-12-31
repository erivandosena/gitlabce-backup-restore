FROM alpine:3.16
RUN apk add --no-cache bash curl tar gzip mc kubectl
WORKDIR /app
COPY scripts/restore.sh /app/restore.sh
RUN chmod +x /app/restore.sh
CMD ["/app/restore.sh"]
