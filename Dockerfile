FROM alpine:latest

RUN apk --no-cache add jq bash curl

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
