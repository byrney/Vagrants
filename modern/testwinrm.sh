#!/bin/bash

set -e

PORT=55985
echo "trying to connect on $PORT"

curl --header "Content-Type: application/soap+xml;charset=UTF-8" --header "WSMANIDENTIFY: unauthenticated" http://127.0.0.1:$PORT/wsman --data \
    '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:wsmid="http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd"><s:Header/><s:Body><wsmid:Identify/></s:Body></s:Envelope>'

echo

echo "Trying to authenticate"

curl --header "Content-Type: application/soap+xml;charset=UTF-8" http://127.0.0.1:$PORT/wsman --basic -u 'IEUser:Passw0rd!' --data '
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:wsmid="http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd">
<s:Header/><s:Body><wsmid:Identify/></s:Body></s:Envelope>'

echo 
echo "done"
