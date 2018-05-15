FROM openfrontier/gerrit:2.15.1

MAINTAINER Sunil Kumar Rana <sunil.k.rana@accenture.com>

# Environment variables
ENV GERRIT_USERNAME gerrit
ENV GERRIT_PASSWORD gerrit
ENV JENKINS_USERNAME jenkins
ENV JENKINS_PASSWORD jenkins
ENV JENKINS_PREFIX jenkins
ENV GERRIT_PREFIX gerrit
ENV LDAP_PROTOCOL=ldap
ENV ADOP_INTERNAL_LDAP=true
ENV GITWEB_TYPE=gitweb

# Override entrypoint script
USER root
COPY resources/gerrit-entrypoint.sh /docker-entrypoint-init.d/
COPY resources/gerrit-start.sh /docker-entrypoint-init.d/
RUN chmod +x /docker-entrypoint-init.d/gerrit*.sh

# Add libiraries
COPY resources/lib/mysql-connector-java-5.1.21.jar ${GERRIT_HOME}/site_ext/lib/mysql-connector-java-5.1.21.jar
RUN curl -fSsL ${GERRITFORGE_URL}/job/plugin-webhooks-${PLUGIN_VERSION}/${GERRITFORGE_ARTIFACT_DIR}/webhooks/webhooks.jar -o ${GERRIT_HOME}/webhooks.jar
# Add utility scripts
COPY resources/scripts/ ${GERRIT_HOME}/adop_scripts/
RUN chmod -R +x ${GERRIT_HOME}/adop_scripts/

# Add site content
COPY resources/site/ ${GERRIT_SITE}

ENTRYPOINT ["/docker-entrypoint-init.d/gerrit-entrypoint.sh"]
EXPOSE 8080 29418
CMD ["/docker-entrypoint-init.d/gerrit-start.sh"]

USER $GERRIT_USER
