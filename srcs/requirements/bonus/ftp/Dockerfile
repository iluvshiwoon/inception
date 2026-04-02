FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp_setup.sh /usr/local/bin/ftp_setup.sh
RUN chmod +x /usr/local/bin/ftp_setup.sh

RUN mkdir -p /var/run/vsftpd/empty

EXPOSE 21 40000-40005

CMD ["/usr/local/bin/ftp_setup.sh"]
