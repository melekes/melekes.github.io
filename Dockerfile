FROM golang:latest

RUN go get -v github.com/spf13/hugo

RUN mkdir -p /go/src/app
WORKDIR /go/src/app

COPY . /go/src/app

EXPOSE 1313

CMD ['hugo', 'server']
