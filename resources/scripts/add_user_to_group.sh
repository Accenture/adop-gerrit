#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -A <ADMIN_USER> -P <ADMIN_PASSWORD> -u <USER> -b <GERRIT_PREFIX> -g <GROUP>"
    exit 1
}

# Constants
SLEEP_TIME=10
MAX_RETRY=3

while getopts "A:P:u:b:g:" opt; do
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
    b)
      gerrit_prefix=${OPTARG}
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

if [ -z "${admin_user}" ] || [ -z "${admin_password}" ] || [ -z "${user}" ] || [ -z "${gerrit_prefix}" ] || [ -z "${group}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Gerrit Connection"
until curl -sL -w "%{http_code}\\n" "http://localhost:8080/${gerrit_prefix}/" -o /dev/null | grep "200" &> /dev/null
do
    echo "Gerrit unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Adding user \"${user}\" to: ${group}"
# Escape the group name for the URL
group=$(echo "${group}" | sed 's/ /%20/g')
count=0
until [ $count -ge ${MAX_RETRY} ]
do
    ret=$(curl -X PUT -u "${admin_user}:${admin_password}" --write-out "%{http_code}\\n" --silent --output /dev/null "http://localhost:8080/${gerrit_prefix}/a/groups/${group}/members/${user}")
    # | grep "200" &> /dev/null && break
    [[ ${ret} -eq 200  ]] && break
    count=$[$count+1]
    echo "Unable to add user ${user} to group ${group}, response code ${ret}, retry ... ${count}"
    sleep ${SLEEP_TIME}
done
