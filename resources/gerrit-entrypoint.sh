#!/bin/bash
set -e
#Initialize gerrit if gerrit site dir is empty.
#This is necessary when gerrit site is in a volume.
if [ "$1" = '/var/gerrit/gerrit-start.sh' ]; then
  if [ -z "$(ls -A "$GERRIT_SITE")" ]; then
    echo "First time initialize gerrit..."
    java -jar "${GERRIT_WAR}" init --batch --no-auto-start -d "${GERRIT_SITE}"
    #All git repositories must be removed in order to be recreated at the secondary init below.
    rm -rf "${GERRIT_SITE}/git"

    # Add site extensions
    cp -uR ${GERRIT_HOME}/site_ext/* ${GERRIT_SITE}/
  fi

  #Customize gerrit.config

  #Section gerrit
  [ -z "${REPO_PATH}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gerrit.basePath "${REPO_PATH}"
  [ -z "${WEBURL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gerrit.canonicalWebUrl "${WEBURL}"
  [ -z "${SCREEN_UI}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gerrit.changeScreen "${SCREEN_UI}"

  #Section database
  if [ "${DATABASE_TYPE}" = 'postgresql' ]; then
    git config -f "${GERRIT_SITE}/etc/gerrit.config" database.type "${DATABASE_TYPE}"
    [ -z "${DB_PORT_5432_TCP_ADDR}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.hostname "${DB_PORT_5432_TCP_ADDR}"
    [ -z "${DB_PORT_5432_TCP_PORT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.port "${DB_PORT_5432_TCP_PORT}"
    [ -z "${DB_ENV_POSTGRES_DB}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.database "${DB_ENV_POSTGRES_DB}"
    [ -z "${DB_ENV_POSTGRES_USER}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.username "${DB_ENV_POSTGRES_USER}"
    [ -z "${DB_ENV_POSTGRES_PASSWORD}" ] || git config -f "${GERRIT_SITE}/etc/secure.config" database.password "${DB_ENV_POSTGRES_PASSWORD}"
  elif [ "${DATABASE_TYPE}" = 'mysql' ]; then
    git config -f "${GERRIT_SITE}/etc/gerrit.config" database.type "${DATABASE_TYPE}"
    [ -z "${DB_HOSTNAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.hostname "${DB_HOSTNAME}"
    [ -z "${DB_PORT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.port "${DB_PORT}"
    [ -z "${DB_NAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.database "${DB_NAME}"
    [ -z "${DB_USER}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" database.username "${DB_USER}"
    [ -z "${DB_PASSWORD}" ] || git config -f "${GERRIT_SITE}/etc/secure.config" database.password "${DB_PASSWORD}"
  fi

  #Section auth
  [ -z "${AUTH_LOGOUTURL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" auth.logoutUrl "${AUTH_LOGOUTURL}"
  [ -z "${AUTH_TRUST_CONTAINER_AUTH}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" auth.trustContainerAuth "${AUTH_TRUST_CONTAINER_AUTH}"

  #Section ldap
  if [ "${AUTH_TYPE}" = 'LDAP' ] || [ "${AUTH_TYPE}" = 'HTTP_LDAP' ]; then
    git config -f "${GERRIT_SITE}/etc/gerrit.config" auth.type "${AUTH_TYPE}"
    git config -f "${GERRIT_SITE}/etc/gerrit.config" auth.gitBasicAuth true
    [ -z "${LDAP_SERVER}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.server "ldap://${LDAP_SERVER}"
    [ -z "${LDAP_SSLVERIFY}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.sslVerify "${LDAP_SSLVERIFY}"
    [ -z "${LDAP_GROUPSVISIBLETOALL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.groupsVisibleToAll "${LDAP_GROUPSVISIBLETOALL}"
    [ -z "${LDAP_USERNAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.username "${LDAP_USERNAME}"
    [ -z "${LDAP_PASSWORD}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.password "${LDAP_PASSWORD}"
    [ -z "${LDAP_REFERRAL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.referral "${LDAP_REFERRAL}"
    [ -z "${LDAP_READTIMEOUT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.readTimeout "${LDAP_READTIMEOUT}"
    [ -z "${LDAP_ACCOUNTBASE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.accountBase "${LDAP_ACCOUNTBASE}"
    [ -z "${LDAP_ACCOUNTSCOPE}" ] || git config -f  "${GERRIT_SITE}/etc/gerrit.config" ldap.accountScope "${LDAP_ACCOUNTSCOPE}"
    [ -z "${LDAP_ACCOUNTPATTERN}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.accountPattern "${LDAP_ACCOUNTPATTERN}"
    [ -z "${LDAP_ACCOUNTFULLNAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.accountFullName "${LDAP_ACCOUNTFULLNAME}"
    [ -z "${LDAP_ACCOUNTEMAILADDRESS}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.accountEmailAddress "${LDAP_ACCOUNTEMAILADDRESS}"
    [ -z "${LDAP_ACCOUNTSSHUSERNAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.accountSshUserName "${LDAP_ACCOUNTSSHUSERNAME}"
    [ -z "${LDAP_ACCOUNTMEMBERFIELD}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.accountMemberField "${LDAP_ACCOUNTMEMBERFIELD}"
    [ -z "${LDAP_FETCHMEMBEROFEAGERLY}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.fetchMemberOfEagerly "${LDAP_FETCHMEMBEROFEAGERLY}"
    [ -z "${LDAP_GROUPBASE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.groupBase "${LDAP_GROUPBASE}"
    [ -z "${LDAP_GROUPSCOPE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.groupScope "${LDAP_GROUPSCOPE}"
    [ -z "${LDAP_GROUPPATTERN}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.groupPattern "${LDAP_GROUPPATTERN}"
    [ -z "${LDAP_GROUPMEMBERPATTERN}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.groupMemberPattern "${LDAP_GROUPMEMBERPATTERN}"
    [ -z "${LDAP_GROUPNAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.groupName "${LDAP_GROUPNAME}"
    [ -z "${LDAP_LOCALUSERNAMETOLOWERCASE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.localUsernameToLowerCase "${LDAP_LOCALUSERNAMETOLOWERCASE}"
    [ -z "${LDAP_AUTHENTICATION}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.authentication "${LDAP_AUTHENTICATION}"
    [ -z "${LDAP_USECONNECTIONPOOLING}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.useConnectionPooling "${LDAP_USECONNECTIONPOOLING}"
    [ -z "${LDAP_CONNECTTIMEOUT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" ldap.connectTimeout "${LDAP_CONNECTTIMEOUT}"
  fi

  # section container
  [ -z "${JAVA_HEAPLIMIT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" container.heapLimit "${JAVA_HEAPLIMIT}"
  [ -z "${JAVA_OPTIONS}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" container.javaOptions "${JAVA_OPTIONS}"
  [ -z "${JAVA_SLAVE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" container.slave "${JAVA_SLAVE}"

  #Section sendemail
  if [ -z "${SMTP_SERVER}" ]; then
    git config -f "${GERRIT_SITE}/etc/gerrit.config" sendemail.enable false
  else
    git config -f "${GERRIT_SITE}/etc/gerrit.config" sendemail.smtpServer "${SMTP_SERVER}"
  fi

  #Section plugins
  git config -f "${GERRIT_SITE}/etc/gerrit.config" plugins.allowRemoteAdmin true

  #Section httpd
  [ -z "${HTTPD_LISTENURL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" httpd.listenUrl "${HTTPD_LISTENURL}"

  #Section user
  [ -z "${USER_NAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" user.name "${USER_NAME}"
  [ -z "${USER_EMAIL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" user.email "${USER_EMAIL}"

  #Section download
  [ -z "${DOWNLOAD_SCHEME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" download.scheme "${DOWNLOAD_SCHEME}"

  #Section Garbage-Collection (gc)
  [ -z "${GC_START_TIME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gc.startTime "${GC_START_TIME}"
  [ -z "${GC_INTERVAL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gc.interval "${GC_INTERVAL}"
  [ -z "${GC_AGGRESSIVE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gc.aggressive "${GC_AGGRESSIVE}"

  #Section gitweb
  [ -z "${GITWEB_TYPE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.type "${GITWEB_TYPE}"
  [ -z "${GITWEB_URL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.url "${GITWEB_URL}"
  [ -z "${GITWEB_PROJECT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.project "${GITWEB_PROJECT}"
  [ -z "${GITWEB_REVISION}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.revision "${GITWEB_REVISION}"
  [ -z "${GITWEB_BRANCH}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.branch "${GITWEB_BRANCH}"
  [ -z "${GITWEB_FILE_HISTORY}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.filehistory "${GITWEB_FILE_HISTORY}"
  [ -z "${GITWEB_LINKNAME}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.linkname "${GITWEB_LINKNAME}"
  [ -z "${GITWEB_REPOSITORIES_FOLDER}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.repositoriesFolder "${GITWEB_REPOSITORIES_FOLDER}"
  [ -z "${GITWEB_ROOTTREE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.roottree "${GITWEB_ROOTTREE}"
  [ -z "${GITWEB_FILE}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" gitweb.file "${GITWEB_FILE}"

  #Section RTC
  [ -z "${RTC_URL}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" rtcValidator.url "${RTC_URL}"
  [ -z "${RTC_ENABLE_INTEGRATION}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" rtcValidator.enableRTCIntegration "${RTC_ENABLE_INTEGRATION}"
  [ -z "${RTC_REQUIRE_WORK_ITEM_COMMENT}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" rtcValidator.requireWorkItemComment "${RTC_REQUIRE_WORK_ITEM_COMMENT}"
  [ -z "${RTC_ABORT_PUSH_ON_INVALID_WORK}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" rtcValidator.abortPushOnInvalidWorkItemNum "${RTC_ABORT_PUSH_ON_INVALID_WORK}"
  [ -z "${RTC_WORK_ITEM_SEARCH_STRING}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" rtcValidator.workItemSearchString "${RTC_WORK_ITEM_SEARCH_STRING}"
  [ -z "${RTC_ENABLED_FOR_PROJECTS}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" rtcValidator.enabledForProjects "${RTC_ENABLED_FOR_PROJECTS}"

  #Section commentLink "RTC"
  [ -z "${RTC_COMMENTLINK_MATCH}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" commentLink.RTC.match "${RTC_COMMENTLINK_MATCH}"
  [ -z "${RTC_COMMENTLINK_HTML}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" commentLink.RTC.html "${RTC_COMMENTLINK_HTML}"
  [ -z "${RTC_COMMENTLINK_ASSOCIATION}" ] || git config -f "${GERRIT_SITE}/etc/gerrit.config" commentLink.RTC.association "${RTC_COMMENTLINK_ASSOCIATION}"

  echo "Upgrading gerrit..."
  java -jar "${GERRIT_WAR}" init --batch -d "${GERRIT_SITE}"
  if [ "${REINDEX}" = "TRUE" ]; then
    java -jar "${GERRIT_WAR}" reindex --recheck-mergeable -d "${GERRIT_SITE}"
  fi
  if [ $? -eq 0 ]; then
    echo "Upgrading is OK."
  else
    echo "Something wrong..."
    cat "${GERRIT_SITE}/logs/error_log"
  fi
fi

 # Plugins Section: Move plugins to the correct folder
cp /var/gerrit/commit-message-rtc-work-item-validator-0.0.2.jar /var/gerrit/review_site/plugins/

if [ "${SKIP_INIT}" != "TRUE" ] || [ -z "${SKIP_INIT}" ]; then
  echo "Starting gerrit init script"
  nohup /var/gerrit/adop\_scripts/gerrit_init.sh &
  exec "$@"
else
  exec "$@"
fi
