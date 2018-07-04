#!/bin/bash
# Setup Nexus Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1

echo "Setting Up Nexus in Project $GUID-nexus"
oc new-app -f https://raw.githubusercontent.com/franredhat/appdev-mitzicom/master/Infrastructure/templates/nexus3-persistent-template.yaml -n $GUID-nexus
