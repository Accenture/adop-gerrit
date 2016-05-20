FROM openfrontier/gerrit:2.10.x

MAINTAINER Nick Griffin, <nicholas.griffin>

# Environment variables
ENV GERRIT_USERNAME gerrit
ENV GERRIT_PASSWORD gerrit
ENV JENKINS_USERNAME jenkins
ENV JENKINS_PASSWORD jenkins
ENV JENKINS_PREFIX jenkins
ENV GERRIT_PREFIX gerrit

# Override entrypoint script
USER root
COPY resources/gerrit-entrypoint.sh ${GERRIT_HOME}/
RUN chmod +x ${GERRIT_HOME}/gerrit*.sh

# Add utility scripts
COPY resources/scripts/ ${GERRIT_HOME}/adop_scripts/
RUN chmod -R +x ${GERRIT_HOME}/adop_scripts/

# Add site content
COPY resources/site/ ${GERRIT_HOME}/site_ext/

USER $GERRIT_USER
