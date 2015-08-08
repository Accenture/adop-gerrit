#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -A <ADMIN_USER> -P <ADMIN_PASSWORD> -u <USER> -g <GROUP>"
    exit 1
}

# Constants
SLEEP_TIME=5

while getopts "A:P:u:g:" opt; do
  case $opt in
    A)
      admin_user=${OPTARG}
      ;;
    P)
      admin_password=${OPTARG}
      ;;
    u)
      user=${OPTARG}
      ;;
    g)
      group=${OPTARG}
      ;;
    *)
      echo "Invalid parameter(s) or option(s)."
      usage
      ;;
  esac
done

if [ -z "${admin_user}" ] || [ -z "${admin_password}" ] || [ -z "${user}" ] || [ -z "${group}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Gerrit Connection"
until curl -sL -w "%{http_code}\\n" "http://localhost:8080/gerrit" -o /dev/null | grep "200" &> /dev/null
do
    echo "Gerrit unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Adding user \"${user}\" to: ${group}"
# Escape the group name for the URL
group=$(echo "${group}" | sed 's/ /%20/g')
curl -X PUT -u "${admin_user}:${admin_password}" "http://localhost:8080/gerrit/a/groups/${group}/members/${user}"
