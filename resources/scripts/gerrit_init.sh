#!/bin/bash

set -e

/var/gerrit/adop\_scripts/create\_user.sh -u ${GERRIT_USERNAME} -p ${GERRIT_PASSWORD} -b ${GERRIT_PREFIX}
/var/gerrit/adop\_scripts/create\_user.sh -u ${JENKINS_USERNAME} -p ${JENKINS_PASSWORD} -b ${GERRIT_PREFIX}
/var/gerrit/adop\_scripts/create\_user.sh -u ${INITIAL_ADMIN_USER} -p ${INITIAL_ADMIN_PASSWORD} -b ${GERRIT_PREFIX}
/var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A ${GERRIT_USERNAME} -P ${GERRIT_PASSWORD} -u ${JENKINS_USERNAME} -b ${GERRIT_PREFIX} -g Administrators
/var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A ${GERRIT_USERNAME} -P ${GERRIT_PASSWORD} -u ${INITIAL_ADMIN_USER} -b ${GERRIT_PREFIX} -g "Administrators"

/var/gerrit/adop\_scripts/upload_ssh_key.sh -c jenkins -p 8080 -A ${JENKINS_USERNAME} -P ${JENKINS_PASSWORD} -b ${GERRIT_PREFIX} -j ${JENKINS_PREFIX} -k id_rsa.pub -u self

exit 0
