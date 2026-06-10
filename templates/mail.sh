#!/bin/bash

FROM="from@konstantintutsch.com"
TO="to@konstantintutsch.com"
SUBJECT="${1}"

curl \
    --ssl-reqd \
    --url "smtps://server:465" \
    --user "${FROM}:password" \
    --mail-from "${FROM}" \
    --mail-rcpt "${TO}" \
    --header "Subject: ${SUBJECT}" \
    --header "From: ${HOSTNAME} <${FROM}>" \
    --header "To: Administrator <${TO}>" \
    --form '=(;type=multipart/mixed' --form "=<-;type=text/plain" --form '=)' # =<- is the body from stdin
