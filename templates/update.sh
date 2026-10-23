#!/bin/bash

# Run:
# REPORT_URL="<Uptime Kuma Push URL>" update.sh

report() {
    curl -s -o /dev/null "${REPORT_URL}"
}

report
