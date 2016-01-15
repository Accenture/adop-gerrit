#!/bin/bash

set -e

/var/gerrit/adop\_scripts/create\_user.sh -u gerrit -p gerrit
/var/gerrit/adop\_scripts/create\_user.sh -u jenkins -p jenkins
/var/gerrit/adop\_scripts/create\_user.sh -u john.smith -p Password01
/var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A gerrit -P gerrit -u jenkins -g "Administrators"
/var/gerrit/adop\_scripts/add\_user\_to\_group.sh -A gerrit -P gerrit -u john.smith -g Administrators

exit 0
