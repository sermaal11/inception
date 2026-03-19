#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mysqld --user=mysql --skip-networking &
sleep 5

mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

mysql -u root -p${DB_ROOT_PASSWORD} -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p${DB_ROOT_PASSWORD} -e "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';"
mysql -u root -p${DB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -u root -p${DB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown

exec mysqld --user=mysql