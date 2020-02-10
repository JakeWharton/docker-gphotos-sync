FROM golang:alpine AS build
RUN apk add --no-cache git wget build-base

# From https://github.com/sourcelevel/engine-image-optim/blob/2de5967c666fc3f7f8f24e67c0c445da403a67ef/Dockerfile#L61-L64
ENV JHEAD_VERSION=3.04
RUN wget http://www.sentex.net/~mwandel/jhead/jhead-$JHEAD_VERSION.tar.gz \
    && tar zxf jhead-$JHEAD_VERSION.tar.gz \
    && cd jhead-$JHEAD_VERSION \
    && make \
    && make install

RUN go get github.com/perkeep/gphotos-cdp


FROM alpine:latest
LABEL maintainer="Jake Wharton <jakewharton@gmail.com>"

ENV CRON="" \
    CHECK_URL="" \
    TZ="" \
    CHROMIUM_USER_FLAGS="--no-sandbox"

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
      tzdata@edge \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

COPY --from=build /go/bin/gphotos-cdp /usr/bin/
COPY --from=build /usr/bin/jhead /usr/bin/
COPY root/ /

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
