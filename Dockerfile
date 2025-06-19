# syntax=docker/dockerfile:1

FROM golang:1.18-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY server ./server
RUN apk add --no-cache build-base
RUN cd server \
 && CGO_ENABLED=1 GOOS=linux go build -ldflags="-s" -o /mutex-server -v .

FROM alpine
VOLUME /data
EXPOSE 8080
COPY --from=build --chmod=0755 /mutex-server /
CMD ["/mutex-server", "-addr", "0.0.0.0:8080", "-dbPath", "/data/mutex_site.db"]