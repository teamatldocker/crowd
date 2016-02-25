#!/bin/bash
#
# A helper script for ENTRYPOINT.
#
# If first CMD argument is 'jira', then the script will start jira
# If CMD argument is overriden and not 'jira', then the user wants to run
# his own process.

set -o errexit

function processCrowdProxySettings() {
  if [ -n "${CROWD_PROXY_NAME}" ]; then
    xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${CROWD_PROXY_NAME}" ${CROWD_INSTALL}/apache-tomcat/conf/server.xml
  fi

  if [ -n "${CROWD_PROXY_PORT}" ]; then
    xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${CROWD_PROXY_PORT}" ${CROWD_INSTALL}/apache-tomcat/conf/server.xml
  fi

  if [ -n "${CROWD_PROXY_SCHEME}" ]; then
    xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${CROWD_PROXY_SCHEME}" ${CROWD_INSTALL}/apache-tomcat/conf/server.xml
  fi
}

if [ -n "${CROWD_DELAYED_START}" ]; then
  sleep ${CROWD_DELAYED_START}
fi

processCrowdProxySettings

if [ "$1" = 'crowd' ] || [ "${1:0:1}" = '-' ]; then
  exec /home/crowd/launch.sh
else
  exec "$@"
fi
