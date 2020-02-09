FROM golang:alpine AS build
RUN apk add --no-cache git
RUN go get github.com/perkeep/gphotos-cdp


FROM zenika/alpine-chrome:latest
LABEL maintainer="Jake Wharton <jakewharton@gmail.com>"

ENV CRON=
ENV CHECK_URL=
ENV TZ=

COPY --from=build /go/bin/gphotos-cdp /
COPY root/ /

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
