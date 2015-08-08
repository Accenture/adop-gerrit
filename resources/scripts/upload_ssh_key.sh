#!/bin/bash
set -e

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -c <CONSUL_HOST> -p <CONSUL_PORT> -A <ADMIN_USER> -P <ADMIN_PASSWORD> -k <KEY> -u <USER>"
    exit 1
}

# Constants
SLEEP_TIME=5

while getopts "c:p:A:P:k:u:" opt; do
  case $opt in
    c)
      consul_host=${OPTARG}
      ;;
    p)
      consul_port=${OPTARG}
      ;;
    A)
      admin_user=${OPTARG}
      ;;
    P)
      admin_password=${OPTARG}
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

if [ -z "${consul_host}" ] || [ -z "${consul_port}" ] || [ -z "${admin_user}" ] || [ -z "${admin_password}" ] || [ -z "${key}" ] || [ -z "${user}" ]; then
    echo "Parameters missing"
    usage
fi

echo "Testing Consul Connection"
until curl -sL -w "%{http_code}\\n" "http://${consul_host}:${consul_port}/v1/kv/?recurse" -o /dev/null | grep "200" &> /dev/null
do
    echo "Consul unavailable, sleeping for ${SLEEP_TIME}"
    sleep "${SLEEP_TIME}"
done

echo "Retrieving value: ${key}"
consul_response=$(curl -s -X GET "http://${consul_host}:${consul_port}/v1/kv/${key}")
value=$(echo "${consul_response}" | jq -r '.[]|.Value' | base64 --decode)

echo "Checking if \"${user}\" exists"
if curl -sL -w "%{http_code}\\n" "http://localhost:8080/gerrit/accounts/${user}" -o /dev/null | grep "404" &> /dev/null; then
    echo "Creating account: ${user}"
    curl -X PUT -u "${admin_user}:${admin_password}" "http://localhost:8080/gerrit/a/accounts/${user}"
fi

echo "Uploading key to Gerrit user \"${user}\""
curl -X POST -u "${admin_user}:${admin_password}" -d "${value}" "http://localhost:8080/gerrit/a/accounts/${user}/sshkeys"