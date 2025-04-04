FROM golang AS builder
WORKDIR /root
RUN git clone https://github.com/nezhahq/agent
WORKDIR /root/agent
RUN go generate ./...
WORKDIR /root/agent/cmd/agent
RUN env CGO_ENABLED=0 \
    go build -v -trimpath -ldflags \
    "-s -w -X github.com/nezhahq/agent/pkg/monitor.Version=1.10.0"
FROM alpine
RUN apk add --no-cache util-linux tzdata
COPY --from=builder /root/agent/cmd/agent/agent /cgent
ENV TZ=Asia/Shanghai \
    NEZHA_TLS=false \
    NEZHA_DEBUG=true \
    NEZHA_DISABLE_AUTO_UPDATE=true
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
