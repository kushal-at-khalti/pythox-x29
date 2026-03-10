FROM coredns/coredns:1.9.1

LABEL maintainer=<system@khalti.com>

ARG DATACENTER="dc1"

COPY ./coredns-config /coredns-config
COPY ./common /common
COPY ./datacenter/${DATACENTER} /datacenter

CMD ["-conf", "/coredns-config/Corefile"]
