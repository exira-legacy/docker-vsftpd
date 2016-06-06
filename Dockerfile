FROM exira/base:3.4.0

MAINTAINER exira.com <info@exira.com>

ENV VSFTPD_ALPINE_VERSION=3.0.3-r1 \
    FTP_USER=**String** \
    FTP_PASS=**Random** \
    LOG_STDOUT=**Boolean**

RUN \
    # Install build and runtime packages
    build_pkgs="build-base curl linux-pam-dev tar" && \
    runtime_pkgs="bash ca-certificates openssl" && \
    apk update && \
    apk upgrade && \
    apk --update --no-cache add vsftpd="${VSFTPD_ALPINE_VERSION}" ${build_pkgs} ${runtime_pkgs} && \

    # get us pam_pwdfile
    mkdir pam_pwdfile && \
    cd pam_pwdfile && \
    curl -sSL https://github.com/tiwe-de/libpam-pwdfile/archive/v1.0.tar.gz | tar xz --strip 1 && \
    make install && \
    cd .. && \
    rm -rf pam_pwdfile && \

    # setup some structure
    mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /home/vsftpd && \
    mkdir -p /conf/vsftpd && \
    chown -R ftp:ftp /home/vsftpd && \

    # add www-data user
    mkdir -p /home/www-data && \
    addgroup -g 433 -S www-data && \
    adduser -u 431 -S -D -G www-data -h /home/www-data -s /sbin/nologin www-data && \
    chown -R www-data:www-data /home/www-data && \

    # remove dev dependencies
    apk del ${build_pkgs} && \

    # other clean up
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd && \

    # Get decent Linux line endings
    dos2unix /etc/vsftpd/vsftpd.conf && \
    dos2unix /etc/pam.d/vsftpd_virtual && \
    dos2unix /usr/sbin/run-vsftpd

VOLUME /conf/vsftpd
VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21 21100 21101 21102 21103 21104 21105 21106 21107 21108 21109 21110

CMD ["/usr/sbin/run-vsftpd"]
