FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init_db.sh /init_db.sh

RUN chmod +x /init_db.sh

CMD ["/init_db.sh"]

