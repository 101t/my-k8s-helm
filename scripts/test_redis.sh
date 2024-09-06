#!/bin/bash

# Function to test Redis communication with password
function test_redis_connection_with_password() {
  local host="$1"
  local port="$2"
  local password="$3"

  echo "Testing Redis connection with password to $host:$port"

  redis-cli -h "$host" -p "$port" -a "$password" ping

  if [[ $? -eq 0 ]]; then
    echo "Redis connection with password successful"
  else
    echo "Redis connection with password failed"
  fi
}

# Function to test Redis communication without password
function test_redis_connection_without_password() {
  local host="$1"
  local port="$2"

  echo "Testing Redis connection without password to $host:$port"

  redis-cli -h "$host" -p "$port" ping

  if [[ $? -eq 0 ]]; then
    echo "Redis connection without password successful"
  else
    echo "Redis connection without password failed"
  fi
}

# Function to check if a variable is empty or null
function is_empty_or_null() {
  [[ -z "$1" ]] && return 0 || return 1
}

# Read default environment variables
REDIS_HOST=${REDIS_HOST:-'127.0.0.1'}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_PASS=${REDIS_PASS:-''}

if is_empty_or_null "$REDIS_PASS"; then
  test_redis_connection_without_password $REDIS_HOST $REDIS_PORT
else
  test_redis_connection_with_password $REDIS_HOST $REDIS_PORT $REDIS_PASS
fi
