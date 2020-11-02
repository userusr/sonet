FROM gitlab/gitlab-ce:13.4.3-ce.0

LABEL project="{{ project }}"

COPY certs /certs
RUN cat /certs/ca.crt >> /opt/gitlab/embedded/ssl/cert.pem
