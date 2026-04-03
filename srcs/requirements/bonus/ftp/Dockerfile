FROM debian:bookworm

RUN apt-get update && apt-get install -y python3-pyftpdlib

COPY tools/ftp_setup.sh /usr/local/bin/ftp_setup.sh
RUN chmod +x /usr/local/bin/ftp_setup.sh

RUN mkdir -p /var/ftp

EXPOSE 21 40000-40005

CMD ["/usr/local/bin/ftp_setup.sh"]