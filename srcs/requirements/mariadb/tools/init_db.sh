#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo "Checking MariaDB installation..."

FRESH_INSTALL=0
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Fresh install detected. Installing base database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    FRESH_INSTALL=1
else
    echo "MariaDB data directory already exists."
fi

echo "Starting temporary MariaDB to configure/update permissions..."
# Arrancamos sin red para realizar tareas administrativas de forma segura
mysqld_safe --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
pid="$!"

echo "Waiting for MariaDB to start..."
until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
    sleep 1
done

echo "Running SQL configuration..."

# Comandos comunes que queremos asegurar SIEMPRE (idempotentes)
SQL_COMMANDS="
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
"

if [ "$FRESH_INSTALL" -eq 1 ]; then
    # En instalación nueva, root aún no tiene password (o usa socket auth)
    echo "Applying initial configuration and setting root password..."
    mysql -u root --socket=/var/run/mysqld/mysqld.sock <<EOF
$SQL_COMMANDS
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';
FLUSH PRIVILEGES;
EOF
else
    # En instalación existente, root ya tiene password
    echo "Updating permissions on existing database..."
    mysql -u root -p"${DB_ROOT_PASSWORD}" --socket=/var/run/mysqld/mysqld.sock <<EOF
$SQL_COMMANDS
EOF
fi

echo "Configuration applied."

# Debug: Ver tabla de usuarios para confirmar
mysql -u root -p"${DB_ROOT_PASSWORD}" --socket=/var/run/mysqld/mysqld.sock -e "SELECT User, Host FROM mysql.user;"

# Parar servidor temporal
echo "Stopping temporary server..."
mysqladmin -u root -p"${DB_ROOT_PASSWORD}" --socket=/var/run/mysqld/mysqld.sock shutdown

echo "Starting MariaDB server (Final)..."
exec mysqld --user=mysql --console