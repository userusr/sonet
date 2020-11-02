FROM coredns/coredns:1.7.1

LABEL project="{{ project }}"

COPY Corefile /etc/coredns/Corefile
COPY zones /etc/coredns/zones/

CMD ["-conf", "/etc/coredns/Corefile"]
