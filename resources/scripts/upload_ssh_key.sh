#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -c <host> -p <port> -A <username> -P <password> -k <KEY> -u <USER>"
    exit 1
}

# Constants
SLEEP_TIME=5

while getopts "c:p:A:P:k:u:" opt; do
  case $opt in
    c)
      host=${OPTARG}
      ;;
    p)
      port=${OPTARG}
      ;;
    A)
      username=${OPTARG}
      ;;
    P)
      password=${OPTARG}
      ;;
    k)
      key=${OPTARG}
      ;;
    u)
      user=${OPTARG}
      ;;
    *)
      echo "Invalid parameter(s) or option(s)."
      usage
      ;;
  esac
done

if [ -z "${host}" ] || [ -z "${port}" ] || [ -z "${username}" ] || [ -z "${password}" ] || [ -z "${key}" ] || [ -z "${user}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Jenkins Connection & Key Presence"
until curl -sL --output /dev/null --silent --write-out "%{http_code}\\n" \
    -u ${username}:${password} \
    "http://${host}:${port}/jenkins/userContent/${key}" -o /dev/null | grep "200" &> /dev/null
do
    echo "Jenkins or key unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Retrieving value: ${key}"
ssh_key=$(curl -s -X GET -u ${username}:${password} "http://${host}:${port}/jenkins/userContent/${key}")
# value=$(echo "${ssh_key}" | jq -r '.[]|.Value' | base64 --decode)

echo "Checking if \"${user}\" exists"
if curl -sL -w "%{http_code}\\n" "http://localhost:8080/gerrit/accounts/${user}" -o /dev/null | grep "404" &> /dev/null; then
    echo "User does not exist: ${user}"
    exit 1
fi

echo "Uploading key to Gerrit user \"${user}\""
curl -X POST -u "${username}:${password}" -d "${ssh_key}" "http://localhost:8080/gerrit/a/accounts/${user}/sshkeys"