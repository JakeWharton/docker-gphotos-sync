FROM golang:alpine AS build
RUN apk add --no-cache git
RUN apk add --no-cache tzdata
RUN go get github.com/perkeep/gphotos-cdp


FROM alpine:latest
LABEL maintainer="Jake Wharton <jakewharton@gmail.com>"

ENV CRON=
ENV CHECK_URL=
ENV TZ=

# Installs latest Chromium package.
RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community > /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && apk add --no-cache \
      libstdc++@edge \
      chromium@edge \
      harfbuzz@edge \
      nss@edge \
      freetype@edge \
      ttf-freefont@edge \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

COPY --from=build /go/bin/gphotos-cdp /
COPY root/ /

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
