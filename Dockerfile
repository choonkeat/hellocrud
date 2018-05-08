FROM golang:alpine

RUN apk add --no-cache git make && \
    go get -u -t github.com/volatiletech/sqlboiler && \
    go get golang.org/x/tools/cmd/goimports && \
    go get -u -d github.com/mattes/migrate/cli github.com/lib/pq && \
    go build -tags 'postgres' -o /usr/local/bin/migrate github.com/mattes/migrate/cli
