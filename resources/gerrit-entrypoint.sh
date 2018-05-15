#!/bin/bash
set -e

set_gerrit_config() {
  su-exec ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/gerrit.config" "$@"
}

set_secure_config() {
  su-exec ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/secure.config" "$@"
}

if [ -n "${JAVA_HEAPLIMIT}" ]; then
  JAVA_MEM_OPTIONS="-Xmx${JAVA_HEAPLIMIT}"
fi

if [ "$1" = "/docker-entrypoint-init.d/gerrit-start.sh" ]; then
  # If you're mounting ${GERRIT_SITE} to your host, you this will default to root.
  # This obviously ensures the permissions are set correctly for when gerrit starts.
  echo "Inside docker entrypoint.."
  find "${GERRIT_SITE}/" ! -user `id -u ${GERRIT_USER}` -exec chown ${GERRIT_USER} {} \;
  find "${REPO_PATH}/" ! -user `id -u ${GERRIT_USER}` -exec chown ${GERRIT_USER} {} \;
  
  # Initialize Gerrit if ${GERRIT_SITE}/git is empty.
  if [ -z "$(ls -A "$GERRIT_SITE/git")" ]; then
    echo "1st Init...First time initialize gerrit..."
    su-exec ${GERRIT_USER} java ${JAVA_OPTIONS} ${JAVA_MEM_OPTIONS} -jar "${GERRIT_WAR}" init --batch --no-auto-start -d "${GERRIT_SITE}" ${GERRIT_INIT_ARGS}
    #All git repositories must be removed when database is set as postgres or mysql
    #in order to be recreated at the secondary init below.
    #Or an execption will be thrown on secondary init.
    [ ${#DATABASE_TYPE} -gt 0 ] && rm -rf "${GERRIT_SITE}/git"
  fi
  
  # Install external plugins
  echo "Adding eEXTERNAL PLUGINS........."
  su-exec ${GERRIT_USER} cp -f ${GERRIT_HOME}/delete-project.jar ${GERRIT_SITE}/plugins/delete-project.jar
  su-exec ${GERRIT_USER} cp -f ${GERRIT_HOME}/events-log.jar ${GERRIT_SITE}/plugins/events-log.jar
  su-exec ${GERRIT_USER} cp -f ${GERRIT_HOME}/importer.jar ${GERRIT_SITE}/plugins/importer.jar
  su-exec ${GERRIT_USER} cp -f ${GERRIT_HOME}/webhooks.jar ${GERRIT_SITE}/plugins/webhooks.jar
 
  #Customize gerrit.config

  #Section gerrit
  [ -z "${REPO_PATH}" ] || set_gerrit_config gerrit.basePath "${REPO_PATH}"
  [ -z "${WEBURL}" ] || set_gerrit_config gerrit.canonicalWebUrl "${WEBURL}"
  [ -z "${SCREEN_UI}" ] || set_gerrit_config gerrit.changeScreen "${SCREEN_UI}"

  #Section database
  if [ "${DATABASE_TYPE}" = 'postgresql' ]; then
    set_gerrit_config database.type "${DATABASE_TYPE}"
    [ -z "${DB_PORT_5432_TCP_ADDR}" ] || set_gerrit_config database.hostname "${DB_PORT_5432_TCP_ADDR}"
    [ -z "${DB_PORT_5432_TCP_PORT}" ] || set_gerrit_config database.port "${DB_PORT_5432_TCP_PORT}"
    [ -z "${DB_ENV_POSTGRES_DB}" ] || set_gerrit_config database.database "${DB_ENV_POSTGRES_DB}"
    [ -z "${DB_ENV_POSTGRES_USER}" ] || set_gerrit_config database.username "${DB_ENV_POSTGRES_USER}"
    [ -z "${DB_ENV_POSTGRES_PASSWORD}" ] || set_secure_config database.password "${DB_ENV_POSTGRES_PASSWORD}"
  elif [ "${DATABASE_TYPE}" = 'mysql' ]; then
    set_gerrit_config database.type "${DATABASE_TYPE}"
    [ -z "${DB_HOSTNAME}" ] || set_gerrit_config database.hostname "${DB_HOSTNAME}"
    [ -z "${DB_PORT}" ] || set_gerrit_config database.port "${DB_PORT}"
    [ -z "${DB_NAME}" ] || set_gerrit_config database.database "${DB_NAME}"
    [ -z "${DB_USER}" ] || set_gerrit_config database.username "${DB_USER}"
    [ -z "${DB_PASSWORD}" ] || set_secure_config database.password "${DB_PASSWORD}"
  fi

  #Section auth
  [ -z "${AUTH_LOGOUTURL}" ] || set_gerrit_config auth.logoutUrl "${AUTH_LOGOUTURL}"
  [ -z "${AUTH_TRUST_CONTAINER_AUTH}" ] || set_gerrit_config auth.trustContainerAuth "${AUTH_TRUST_CONTAINER_AUTH}"

  #Section ldap
  if [ "${AUTH_TYPE}" = 'LDAP' ] || [ "${AUTH_TYPE}" = 'HTTP_LDAP' ]; then
    set_gerrit_config auth.type "${AUTH_TYPE}"
    set_gerrit_config auth.gitBasicAuth true
    set_gerrit_config auth.gitBasicAuthPolicy HTTP_LDAP
    [ -z "${LDAP_SERVER}" ] || set_gerrit_config ldap.server "${LDAP_PROTOCOL}://${LDAP_SERVER}"
    [ -z "${LDAP_SSLVERIFY}" ] || set_gerrit_config ldap.sslVerify "${LDAP_SSLVERIFY}"
    [ -z "${LDAP_GROUPSVISIBLETOALL}" ] || set_gerrit_config ldap.groupsVisibleToAll "${LDAP_GROUPSVISIBLETOALL}"
    [ -z "${LDAP_USERNAME}" ] || set_gerrit_config ldap.username "${LDAP_USERNAME}"
    [ -z "${LDAP_PASSWORD}" ] || set_secure_config ldap.password "${LDAP_PASSWORD}"
    [ -z "${LDAP_REFERRAL}" ] || set_gerrit_config ldap.referral "${LDAP_REFERRAL}"
    [ -z "${LDAP_READTIMEOUT}" ] || set_gerrit_config ldap.readTimeout "${LDAP_READTIMEOUT}"
    [ -z "${LDAP_ACCOUNTBASE}" ] || set_gerrit_config ldap.accountBase "${LDAP_ACCOUNTBASE}"
    [ -z "${LDAP_ACCOUNTSCOPE}" ] || set_gerrit_config ldap.accountScope "${LDAP_ACCOUNTSCOPE}"
    [ -z "${LDAP_ACCOUNTPATTERN}" ] || set_gerrit_config ldap.accountPattern "${LDAP_ACCOUNTPATTERN}"
    [ -z "${LDAP_ACCOUNTFULLNAME}" ] || set_gerrit_config ldap.accountFullName "${LDAP_ACCOUNTFULLNAME}"
    [ -z "${LDAP_ACCOUNTEMAILADDRESS}" ] || set_gerrit_config ldap.accountEmailAddress "${LDAP_ACCOUNTEMAILADDRESS}"
    [ -z "${LDAP_ACCOUNTSSHUSERNAME}" ] || set_gerrit_config ldap.accountSshUserName "${LDAP_ACCOUNTSSHUSERNAME}"
    [ -z "${LDAP_ACCOUNTMEMBERFIELD}" ] || set_gerrit_config ldap.accountMemberField "${LDAP_ACCOUNTMEMBERFIELD}"
    [ -z "${LDAP_FETCHMEMBEROFEAGERLY}" ] || set_gerrit_config ldap.fetchMemberOfEagerly "${LDAP_FETCHMEMBEROFEAGERLY}"
    [ -z "${LDAP_GROUPBASE}" ] || set_gerrit_config ldap.groupBase "${LDAP_GROUPBASE}"
    [ -z "${LDAP_GROUPSCOPE}" ] || set_gerrit_config ldap.groupScope "${LDAP_GROUPSCOPE}"
    [ -z "${LDAP_GROUPPATTERN}" ] || set_gerrit_config ldap.groupPattern "${LDAP_GROUPPATTERN}"
    [ -z "${LDAP_GROUPMEMBERPATTERN}" ] || set_gerrit_config ldap.groupMemberPattern "${LDAP_GROUPMEMBERPATTERN}"
    [ -z "${LDAP_GROUPNAME}" ] || set_gerrit_config ldap.groupName "${LDAP_GROUPNAME}"
    [ -z "${LDAP_LOCALUSERNAMETOLOWERCASE}" ] || set_gerrit_config ldap.localUsernameToLowerCase "${LDAP_LOCALUSERNAMETOLOWERCASE}"
    [ -z "${LDAP_AUTHENTICATION}" ] || set_gerrit_config ldap.authentication "${LDAP_AUTHENTICATION}"
    [ -z "${LDAP_USECONNECTIONPOOLING}" ] || set_gerrit_config ldap.useConnectionPooling "${LDAP_USECONNECTIONPOOLING}"
    [ -z "${LDAP_CONNECTTIMEOUT}" ] || set_gerrit_config ldap.connectTimeout "${LDAP_CONNECTTIMEOUT}"
  fi

  # section container
  [ -z "${JAVA_HEAPLIMIT}" ] || set_gerrit_config container.heapLimit "${JAVA_HEAPLIMIT}"
  [ -z "${JAVA_OPTIONS}" ] || set_gerrit_config container.javaOptions "${JAVA_OPTIONS}"
  [ -z "${JAVA_SLAVE}" ] || set_gerrit_config container.slave "${JAVA_SLAVE}"

  #Section sendemail
  if [ -z "${SMTP_SERVER}" ]; then
    set_gerrit_config sendemail.enable false
  else
    set_gerrit_config sendemail.smtpServer "${SMTP_SERVER}"
  fi

  #Section plugins
  set_gerrit_config plugins.allowRemoteAdmin true

  #Section httpd
  [ -z "${HTTPD_LISTENURL}" ] || set_gerrit_config httpd.listenUrl "${HTTPD_LISTENURL}"

  #Section user
  [ -z "${USER_NAME}" ] || set_gerrit_config user.name "${USER_NAME}"
  [ -z "${USER_EMAIL}" ] || set_gerrit_config user.email "${USER_EMAIL}"


  #Section Garbage-Collection (gc)
  [ -z "${GC_START_TIME}" ] || set_gerrit_config gc.startTime "${GC_START_TIME}"
  [ -z "${GC_INTERVAL}" ] || set_gerrit_config gc.interval "${GC_INTERVAL}"
  [ -z "${GC_AGGRESSIVE}" ] || set_gerrit_config gc.aggressive "${GC_AGGRESSIVE}"

  #Section gitweb
  set_gerrit_config gitweb.cgi "/usr/share/gitweb/gitweb.cgi"
  [ -z "${GITWEB_TYPE}" ] || set_gerrit_config gitweb.type "${GITWEB_TYPE}"
  [ -z "${GITWEB_URL}" ] || set_gerrit_config gitweb.url "${GITWEB_URL}"
  [ -z "${GITWEB_PROJECT}" ] || set_gerrit_config gitweb.project "${GITWEB_PROJECT}"
  [ -z "${GITWEB_REVISION}" ] || set_gerrit_config gitweb.revision "${GITWEB_REVISION}"
  [ -z "${GITWEB_BRANCH}" ] || set_gerrit_config gitweb.branch "${GITWEB_BRANCH}"
  [ -z "${GITWEB_FILE_HISTORY}" ] || set_gerrit_config gitweb.filehistory "${GITWEB_FILE_HISTORY}"
  [ -z "${GITWEB_LINKNAME}" ] || set_gerrit_config gitweb.linkname "${GITWEB_LINKNAME}"
  [ -z "${GITWEB_REPOSITORIES_FOLDER}" ] || set_gerrit_config gitweb.repositoriesFolder "${GITWEB_REPOSITORIES_FOLDER}"
  [ -z "${GITWEB_ROOTTREE}" ] || set_gerrit_config gitweb.roottree "${GITWEB_ROOTTREE}"
  [ -z "${GITWEB_FILE}" ] || set_gerrit_config gitweb.file "${GITWEB_FILE}"

  #Section RTC
  [ -z "${RTC_URL}" ] || set_gerrit_config rtcValidator.url "${RTC_URL}"
  [ -z "${RTC_ENABLE_INTEGRATION}" ] || set_gerrit_config rtcValidator.enableRTCIntegration "${RTC_ENABLE_INTEGRATION}"
  [ -z "${RTC_REQUIRE_WORK_ITEM_COMMENT}" ] || set_gerrit_config rtcValidator.requireWorkItemComment "${RTC_REQUIRE_WORK_ITEM_COMMENT}"
  [ -z "${RTC_ABORT_PUSH_ON_INVALID_WORK}" ] || set_gerrit_config rtcValidator.abortPushOnInvalidWorkItemNum "${RTC_ABORT_PUSH_ON_INVALID_WORK}"
  [ -z "${RTC_WORK_ITEM_SEARCH_STRING}" ] || set_gerrit_config rtcValidator.workItemSearchString "${RTC_WORK_ITEM_SEARCH_STRING}"
  [ -z "${RTC_ENABLED_FOR_PROJECTS}" ] || set_gerrit_config rtcValidator.enabledForProjects "${RTC_ENABLED_FOR_PROJECTS}"

  #Section commentLink "RTC"
  [ -z "${RTC_COMMENTLINK_MATCH}" ] || set_gerrit_config commentLink.RTC.match "${RTC_COMMENTLINK_MATCH}"
  [ -z "${RTC_COMMENTLINK_HTML}" ] || set_gerrit_config commentLink.RTC.html "${RTC_COMMENTLINK_HTML}"
  [ -z "${RTC_COMMENTLINK_ASSOCIATION}" ] || set_gerrit_config commentLink.RTC.association "${RTC_COMMENTLINK_ASSOCIATION}"

  echo "Upgrading gerrit..."
  #java -jar "${GERRIT_WAR}" init --batch -d "${GERRIT_SITE}"
  su-exec ${GERRIT_USER} java ${JAVA_OPTIONS} ${JAVA_MEM_OPTIONS} -jar "${GERRIT_WAR}" init --batch -d "${GERRIT_SITE}" ${GERRIT_INIT_ARGS} --install-all-plugins
  if [ "${REINDEX}" = "TRUE" ]; then
    #java -jar "${GERRIT_WAR}" reindex --recheck-mergeable -d "${GERRIT_SITE}"
    su-exec ${GERRIT_USER} java ${JAVA_OPTIONS} ${JAVA_MEM_OPTIONS} -jar "${GERRIT_WAR}" reindex --verbose -d "${GERRIT_SITE}"
  fi
  if [ $? -eq 0 ]; then
    echo "Upgrading is OK."
  else
    echo "Something wrong..."
    cat "${GERRIT_SITE}/logs/error_log"
  fi
fi

if [ "${SKIP_INIT}" != "TRUE" ] || [ -z "${SKIP_INIT}" ]; then
  echo "2nd Init..Starting gerrit init script"
  nohup /var/gerrit/adop\_scripts/gerrit_init.sh &
  exec "$@"
else
  exec "$@"
fi
