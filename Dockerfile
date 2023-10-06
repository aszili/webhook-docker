FROM        golang:alpine AS build
WORKDIR     /go/src/github.com/adnanh/webhook
RUN         apk add --update --no-cache -t build-deps curl libc-dev gcc libgcc
ARG         WEBHOOK_VERSION
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            tar -xzf webhook.tar.gz --strip 1
RUN         go get -d -v
RUN         CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/webhook

FROM        alpine:edge AS base
RUN         apk add --no-cache git docker-cli docker-cli-compose
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]