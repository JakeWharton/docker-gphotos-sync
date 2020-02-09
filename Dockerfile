FROM ubuntu:latest AS build
WORKDIR /
RUN \
  apt update -q && \
  apt install -q -y git wget && \
  wget -q https://dl.google.com/go/go1.13.7.linux-amd64.tar.gz && \
  tar -C / -xzf go*.tar.gz
ENV GOPATH=/code
WORKDIR /code

RUN /go/bin/go get github.com/perkeep/gphotos-cdp



FROM zenika/alpine-chrome:latest
LABEL maintainer="Jake Wharton <jakewharton@gmail.com>"

ENV CRON=
ENV TZ=

COPY --from=build /code/bin/gphotos-cdp /
COPY root/ /

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
