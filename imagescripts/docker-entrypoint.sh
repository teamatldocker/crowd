#!/bin/bash
#
# A helper script for ENTRYPOINT.
#
# If first CMD argument is 'jira', then the script will start jira
# If CMD argument is overriden and not 'jira', then the user wants to run
# his own process.

set -o errexit

if [ "$1" = 'crowd' ] || [ "${1:0:1}" = '-' ]; then
  exec ${CROWD_INSTALL}/launch.sh
else
  exec "$@"
fi
