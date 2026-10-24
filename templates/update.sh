#!/bin/bash

# Run:
# REPORT_URL="<Uptime Kuma Push URL>" update.sh
#
# DNF Automatic:
# command_format = "env REPORT_URL="<Uptime Kuma Push URL>" <path>/update.sh"

report() {
    curl -s -o /dev/null "${REPORT_URL}"
}

report
