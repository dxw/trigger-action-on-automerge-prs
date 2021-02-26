FROM alpine:latest

LABEL version="1.0.0"
LABEL repository="http://github.com/dxw/trigger-action-on-automerge-prs"
LABEL homepage="http://github.com/dxw/trigger-action-on-automerge-prs"
LABEL maintainer="dxw"

RUN apk --no-cache add jq bash curl

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
