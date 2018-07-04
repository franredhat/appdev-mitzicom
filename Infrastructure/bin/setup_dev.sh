#!/bin/bash
# Setup Development Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

# MongoDB

echo "Creating MongoDB single instance"
oc new-app -f https://raw.githubusercontent.com/franredhat/appdev-mitzicom/master/Infrastructure/templates/mongodb-statefulset-1replicaset.yaml -n ${GUID}-parks-dev
