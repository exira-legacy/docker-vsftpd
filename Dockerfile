FROM exira/base:3.4.0

MAINTAINER exira.com <info@exira.com>

ENV VSFTPD_ALPINE_VERSION=3.0.3-r1 \
    FTP_USER=**String** \
    FTP_PASS=**Random** \
    LOG_STDOUT=**Boolean**

RUN \
    # Install build and runtime packages
    apk update && \
    apk upgrade && \
    apk --update --no-cache add vsftpd="${VSFTPD_ALPINE_VERSION}" db db-utils bash && \

    mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /home/vsftpd && \
    mkdir -p /conf/vsftpd && \
    chown -R ftp:ftp /home/vsftpd && \

    # other clean up
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd /usr/sbin/
COPY virtual-user /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd && \
    chmod +x /usr/sbin/virtual-user && \

    # Get decent Linux line endings
    dos2unix /etc/vsftpd/vsftpd.conf && \
    dos2unix /etc/pam.d/vsftpd_virtual && \
    dos2unix /usr/sbin/run-vsftpd && \
    dos2unix /usr/sbin/virtual-user

VOLUME /conf/vsftpd
VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21 21100 21101 21102 21103 21104 21105 21106 21107 21108 21109 21110

CMD ["/usr/sbin/run-vsftpd"]
