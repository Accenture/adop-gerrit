#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -c <host> -p <port> -A <username> -P <password> -b <GERRIT_PREFIX> -j <JENKINS_PREFIX> -k <KEY> -u <USER>"
    exit 1
}

# Constants
SLEEP_TIME=10

while getopts "c:p:A:P:b:j:k:u:" opt; do
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
    b)
      gerrit_prefix=${OPTARG}
      ;;
    j)
      jenkins_prefix=${OPTARG}
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

if [ -z "${host}" ] || [ -z "${port}" ] || [ -z "${username}" ] || [ -z "${password}" ] || [ -z "${gerrit_prefix}" ] || [ -z "${jenkins_prefix}" ] || [ -z "${key}" ] || [ -z "${user}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Jenkins Connection & Key Presence"
until curl -sL --output /dev/null --silent --write-out "%{http_code}\\n" \
    -u ${username}:${password} \
    "http://${host}:${port}/${jenkins_prefix}/userContent/${key}" -o /dev/null | grep "200" &> /dev/null
do
    echo "Jenkins or key unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Retrieving value: ${key}"
ssh_key=$(curl -s -X GET -u ${username}:${password} "http://${host}:${port}/${jenkins_prefix}/userContent/${key}")

echo "Checking if \"${user}\" exists"
if curl -sL -w "%{http_code}\\n" "http://localhost:8080/${gerrit_prefix}/accounts/${user}" -o /dev/null | grep "404" &> /dev/null; then
    echo "User does not exist: ${user}"
    exit 1
fi

echo "*** Verify key already exists... Gerrit does not do this ..."
# Download the stored key and decode from to UTF-8
# Using echo -e the -n switch from echo allows to remove the trailing \n that echo would add
# The decode part is necessary as Gerrit correctly encode the SSH key and as a result = sign is converted to \u003d
stored_key=$(echo -e $(curl -u ${username}:${password} --silent http://localhost:8080/${gerrit_prefix}/a/accounts/self/sshkeys | grep "ssh_public_key" | awk '{split($0, a, ": "); print a[2]}' | sed 's/[",]//g'))
if [[ "$stored_key" == "$ssh_key" ]]; then
  echo "* Stored key is the same as downloaded, skipping it ..."
  exit 0
else
  echo "* Stored key is not same as downloaded, uploading it ..."
fi

echo "Uploading public-key to Gerrit user \"${user}\""
ret=$(curl -X POST -u "${username}:${password}" -d "${ssh_key}" --output /dev/null --silent --write-out "%{http_code}" "http://localhost:8080/${gerrit_prefix}/a/accounts/${user}/sshkeys")
if [[ ${ret} -eq 201 ]]; then
  echo "Public-key was uploaded"
else
  echo "Public-key was uploaded with the invalid response code: ${ret}"
fi
