#!/bin/bash

set -e
#
if [ ${ADOP_INTERNAL_LDAP} = false ]; then
  # Execute when we are using not ADOP LDAP. It means that LDAP don't have local Jenkins and Gerrit users so we need to create.

  # To get only username we need to trim ${LDAP_USERNAME} because it comes with BASE_DN.
  _LDAP_USERNAME=$(echo ${LDAP_USERNAME} | awk -F ',' '{print $1}' | grep -o -P '(?<=cn=)(.+)')
  # Activate LDAP user in Gerrit.
  /var/gerrit/adop\_scripts/create\_user.sh -u ${_LDAP_USERNAME} -p ${LDAP_PASSWORD} -b ${GERRIT_PREFIX}

  # Activate INITIAL_ADMIN_USER in Gerrit.
  /var/gerrit/adop\_scripts/create\_user.sh -u ${INITIAL_ADMIN_USER} -p ${INITIAL_ADMIN_PASSWORD} -b ${GERRIT_PREFIX}
  # Set INITIAL_ADMIN_USER as Administrator.
  /var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A ${_LDAP_USERNAME} -P ${LDAP_PASSWORD} -u ${INITIAL_ADMIN_USER} -b ${GERRIT_PREFIX} -g Administrators

  # Creating local Jenkins and Gerrit users.
  curl -X PUT -u "${INITIAL_ADMIN_USER}:${INITIAL_ADMIN_PASSWORD}" -H "Content-Type: application/json" -d '{ "name": "Jenkins", "email": "jenkins@ldap.example.com", "groups": [ "Administrators" ] }' "http://localhost:8080/${GERRIT_PREFIX}/a/accounts/jenkins"
  curl -X PUT -u "${INITIAL_ADMIN_USER}:${INITIAL_ADMIN_PASSWORD}" -H "Content-Type: application/json" -d '{ "name": "Gerrit", "groups": [ "Administrators" ] }' "http://localhost:8080/${GERRIT_PREFIX}/a/accounts/gerrit"

  # Uploading public key to Jenkins and Gerrit user.
  /var/gerrit/adop\_scripts/upload_ssh_key.sh -c jenkins -p 8080 -A ${INITIAL_ADMIN_USER} -P ${INITIAL_ADMIN_PASSWORD} -b ${GERRIT_PREFIX} -j ${JENKINS_PREFIX} -k id_rsa.pub -u jenkins
  /var/gerrit/adop\_scripts/upload_ssh_key.sh -c jenkins -p 8080 -A ${INITIAL_ADMIN_USER} -P ${INITIAL_ADMIN_PASSWORD} -b ${GERRIT_PREFIX} -j ${JENKINS_PREFIX} -k id_rsa.pub -u gerrit
else
  # Execute when we are using ADOP LDAP.

  /var/gerrit/adop\_scripts/create\_user.sh -u ${GERRIT_USERNAME} -p ${GERRIT_PASSWORD} -b ${GERRIT_PREFIX}
  /var/gerrit/adop\_scripts/create\_user.sh -u ${JENKINS_USERNAME} -p ${JENKINS_PASSWORD} -b ${GERRIT_PREFIX}
  /var/gerrit/adop\_scripts/create\_user.sh -u ${INITIAL_ADMIN_USER} -p ${INITIAL_ADMIN_PASSWORD} -b ${GERRIT_PREFIX}
  /var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A ${GERRIT_USERNAME} -P ${GERRIT_PASSWORD} -u ${JENKINS_USERNAME} -b ${GERRIT_PREFIX} -g Administrators
  /var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A ${GERRIT_USERNAME} -P ${GERRIT_PASSWORD} -u ${INITIAL_ADMIN_USER} -b ${GERRIT_PREFIX} -g "Administrators"

  /var/gerrit/adop\_scripts/upload_ssh_key.sh -c jenkins -p 8080 -A ${JENKINS_USERNAME} -P ${JENKINS_PASSWORD} -b ${GERRIT_PREFIX} -j ${JENKINS_PREFIX} -k id_rsa.pub -u self

fi

exit 0
