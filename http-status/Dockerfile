FROM golang:1.11-alpine as builder

RUN apk update && apk add git ca-certificates make upx

COPY *.go Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress

############################
FROM scratch

COPY --from=builder /go/src/http-status /healthcheck
