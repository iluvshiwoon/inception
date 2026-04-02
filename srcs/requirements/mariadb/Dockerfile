FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/mariadb.sh /usr/local/bin/mariadb.sh
RUN chmod +x /usr/local/bin/mariadb.sh

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Expose the standard MySQL port
EXPOSE 3306

# Run the initialization script
CMD ["/usr/local/bin/mariadb.sh"]
