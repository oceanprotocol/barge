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
# Apache config
# ----------------------------------------------------
RUN a2enmod rewrite
# ----------------------------------------------------
# FTP config
# ----------------------------------------------------
RUN sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf && \
    sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
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