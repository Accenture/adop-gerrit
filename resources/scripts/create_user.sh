#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -u <USER> -p <PASSWORD> -b <GERRIT_PREFIX>"
    exit 1
}

# Constants
SLEEP_TIME=10
MAX_RETRY=10

while getopts "c:p:k:u:b:" opt; do
  case $opt in
    u)
      username=${OPTARG}
      ;;
    b)
      gerrit_prefix=${OPTARG}
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

if [ -z "${username}" ] || [ -z "${password}" ] || [ -z "${gerrit_prefix}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Gerrit Connection"
until curl -sL -w "%{http_code}\\n" "http://localhost:8080/${gerrit_prefix}/login/%23/q/status:open" -o /dev/null | grep "401\|403" &> /dev/null
do
    echo "Gerrit unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Creating user: ${username}"
count=0
until [ $count -ge ${MAX_RETRY} ]
do
  ret=$(curl -X POST --data "username=${username}&password=${password}" --write-out "%{http_code}" --silent --output /dev/null http://localhost:8080/${gerrit_prefix}/login/%23/q/status:open)
  # | grep 302  &> /dev/null && break
  [[ ${ret} -eq 302  ]] && break
  count=$[$count+1]
  echo "Unable to create user ${username}, response code ${ret}, retry ... ${count}"
  sleep ${SLEEP_TIME}
done
