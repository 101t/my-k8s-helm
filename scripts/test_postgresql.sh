#!/bin/bash

# Function to test PostgreSQL communication
function test_postgresql_connection() {
  local host="$1"
  local port="$2"
  local database="$3"
  local user="$4"
  local password="$5"

  echo "Testing PostgreSQL connection to $host:$port for database $database"

  export PGPASSWORD=$password

  # Use psql to connect to PostgreSQL
  psql -h "$host" -p "$port" -d "$database" -U "$user" -w <<EOF
    \q
EOF

  unset PGPASSWORD

  if [[ $? -eq 0 ]]; then
    echo "PostgreSQL connection successful"
  else
    echo "PostgreSQL connection failed"
  fi
}

DB_HOST=${DB_HOST:-'127.0.0.1'}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-'postgres'}
DB_USER=${DB_USER:-'postgres'}
DB_PASS=${DB_PASS:-'postgres'}

# Example usage:
test_postgresql_connection $DB_HOST $DB_PORT $DB_NAME $DB_USER $DB_PASS