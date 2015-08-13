#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -u <USER> -p <PASSWORD>"
    exit 1
}

# Constants
SLEEP_TIME=5

while getopts "c:p:k:u:" opt; do
  case $opt in
    u)
      username=${OPTARG}
      ;;
    p)
      password=${OPTARG}
      ;;
    *)
      echo "Invalid parameter(s) or option(s)."
      usage
      ;;
  esac
done

if [ -z "${username}" ] || [ -z "${password}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Gerrit Connection"
until curl -sL -w "%{http_code}\\n" "http://localhost:8080/gerrit/login/%23/q/status:open" -o /dev/null | grep "401" &> /dev/null
do
    echo "Gerrit unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Creating admin user: ${username}"
curl -X POST --data "username=${username}&password=${password}" http://localhost:8080/gerrit/login/%23/q/status:open