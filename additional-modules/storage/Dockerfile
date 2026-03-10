FROM ubuntu:22.04 AS ceph
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt -y update && apt -y install \
    apache2 \
    vsftpd \
    lsb-release \
    wget \
    curl \
    pgp \
    tzdata \
    vim \
    dnsutils \
    iputils-ping \
    iproute2 \
    jq
# ----------------------------------------------------
# Apache config (allow PUT uploads via WebDAV on /var/www/html)
# ----------------------------------------------------
RUN a2enmod rewrite dav dav_fs && \
    mkdir -p /var/lib/apache2/dav && chown www-data:www-data /var/lib/apache2/dav
RUN echo 'DavLockDB /var/lib/apache2/dav/DavLock' > /etc/apache2/conf-available/dav.conf && \
    echo '<Directory /var/www/html>' >> /etc/apache2/conf-available/dav.conf && \
    echo '  DAV On' >> /etc/apache2/conf-available/dav.conf && \
    echo '  Require all granted' >> /etc/apache2/conf-available/dav.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/dav.conf && \
    a2enconf dav
# ----------------------------------------------------
# FTP config (local user only; credentials from env at runtime)
# ----------------------------------------------------
RUN sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf && \
    echo "local_enable=YES" >> /etc/vsftpd.conf && \
    echo "chroot_local_user=YES" >> /etc/vsftpd.conf && \
    echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf && \
    echo "anonymous_enable=NO" >> /etc/vsftpd.conf && \
    echo "check_shell=NO" >> /etc/vsftpd.conf && \
    echo "userlist_enable=NO" >> /etc/vsftpd.conf
# PAM: auth by password only (no shell/listfile checks that block ftpuser)
RUN echo 'auth required pam_unix.so' > /etc/pam.d/vsftpd && \
    echo 'account required pam_unix.so' >> /etc/pam.d/vsftpd && \
    echo 'session required pam_unix.so' >> /etc/pam.d/vsftpd
RUN wget \
        -q \
        -O- https://download.ceph.com/keys/release.asc | \
        gpg --dearmor > /etc/apt/trusted.gpg.d/ceph.gpg && \
    echo "deb https://download.ceph.com/debian-reef/ $(lsb_release -sc) main" \
        > /etc/apt/sources.list.d/ceph.list && \
    apt -y update && \
    apt install -y ceph radosgw
RUN apt clean && \
    apt autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

FROM ceph AS radosgw
ENV TZ=Etc/UTC
ENV MGR_USERNAME="admin"
ENV MAIN="none"
# ACCESS_KEY, SECRET_KEY, MGR_PASSWORD: pass at runtime (e.g. compose environment) to avoid embedding in image

EXPOSE 7480

COPY ./entrypoint.sh /entrypoint
ENTRYPOINT ["/entrypoint"]