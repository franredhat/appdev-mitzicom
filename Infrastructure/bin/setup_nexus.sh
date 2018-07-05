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

echo "Adding 5000 Port Service and Route"
oc expose dc nexus --port=5000 --name=nexus-registry -n $GUID-nexus
oc create route edge nexus-registry --service=nexus-registry --port=5000 -n $GUID-nexus
