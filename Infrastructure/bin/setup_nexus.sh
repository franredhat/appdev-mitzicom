#!/bin/bash
# Setup Nexus Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1

echo "Setting Up Nexus in Project $GUID-nexus"
oc project $GUID-nexus
oc new-app -f https://raw.githubusercontent.com/franredhat/development-homework/master/Infrastructure/templates/nexus3-persistent-template.yaml

echo "Waiting 10 minutes until Nexus can be configured"
sleep 600

echo "Setting up Nexus readiness and liveness probes"
oc set probe dc/nexus3 --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nexus3 --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/repository/maven-public/

echo "Configuring Nexus with repositories"
curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/wkulhanek/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
chmod +x setup_nexus3.sh
./setup_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}')
rm setup_nexus3.sh

echo "Adding Nexus Registry Route"
oc expose dc nexus3 --port=5000 --name=nexus-registry
oc create route edge nexus-registry --service=nexus-registry --port=5000
