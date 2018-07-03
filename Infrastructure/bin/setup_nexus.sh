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

echo "Waiting until Nexus can be configured"
sleep 400

echo "Configuring Nexus with Wolfgang repositories"
curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/wkulhanek/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
chmod +x setup_nexus3.sh
./setup_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}' -n $GUID-nexus)
rm setup_nexus3.sh

echo "Adding Nexus Registry Route"
oc expose dc nexus3 --port=5000 --name=nexus-registry -n $GUID-nexus
oc create route edge nexus-registry --service=nexus-registry --port=5000 -n $GUID-nexus
