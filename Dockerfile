FROM openfrontier/gerrit:2.10.x

MAINTAINER Nick Griffin, <nicholas.griffin>

ENV GERRIT_USERNAME gerrit
ENV GERRIT_PASSWORD gerrit
ENV JENKINS_USERNAME jenkins
ENV JENKINS_PASSWORD jenkins

# Override entrypoint script
USER root
COPY resources/gerrit-entrypoint.sh ${GERRIT_HOME}/
RUN chmod +x ${GERRIT_HOME}/gerrit*.sh

# Add utility scripts
COPY resources/scripts/ ${GERRIT_HOME}/adop_scripts/
RUN wget https://s3-eu-west-1.amazonaws.com/adop-config/data-deployment/bin/jq-1.4 -O /usr/local/bin/jq && chmod -R +x /usr/local/bin && chmod -R +x ${GERRIT_HOME}/adop_scripts/

USER $GERRIT_USER

# Environment variables
