FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------------
# Install packages
# ----------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
        apache2 \
        vsftpd \
        ceph \
        ceph-mds \
        ceph-mgr \
        ceph-mon \
        ceph-osd \
        radosgw \
        supervisor \
        uuid-runtime \
        dnsutils \
        curl \
        jq && \
    apt-get clean

# ----------------------------------------------------
# Apache config
# ----------------------------------------------------
RUN a2enmod rewrite

# ----------------------------------------------------
# FTP config
# ----------------------------------------------------
RUN sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf && \
    sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf

# ----------------------------------------------------
# Ceph directories
# ----------------------------------------------------
RUN mkdir -p /etc/ceph /var/lib/ceph/mon/ceph-a /var/lib/ceph/osd/ceph-0 /var/lib/ceph/mgr/ceph-a

# ----------------------------------------------------
# Copy bootstrap script
# ----------------------------------------------------
COPY bootstrap-ceph.sh /usr/local/bin/bootstrap-ceph.sh
RUN chmod +x /usr/local/bin/bootstrap-ceph.sh

# ----------------------------------------------------
# Supervisor config
# ----------------------------------------------------
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ----------------------------------------------------
# Expose ports
# ----------------------------------------------------
# Apache
EXPOSE 80       
# FTP data
EXPOSE 20        
# FTP control
EXPOSE 21
# Ceph MON
EXPOSE 6789
# Ceph OSD/MGR
EXPOSE 6800-6900
# RGW S3 + Swift
EXPOSE 7480 

CMD ["/usr/local/bin/bootstrap-ceph.sh"]