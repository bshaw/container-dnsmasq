FROM alpine:latest

RUN apk add --no-cache dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 67 67/udp

ENTRYPOINT [ "dnsmasq", "--no-daemon" ]
