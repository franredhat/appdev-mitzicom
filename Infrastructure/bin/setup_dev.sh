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

# 

echo "Packaging MLBParks"
cd MLBParks
mvn -s ../nexus_settings.xml clean package -DskipTests=true

echo "MLBParks unit tests"
mvn -s ../nexus_settings.xml test

echo "Running MLBParks Code Analyses"
mvn -s ../nexus_settings.xml deploy -DskipTests=true -DaltDeploymentRepository=nexus::default::http://nexus3-$GUID-nexus.apps.na39.openshift.opentlc.com/repository/releases"
 
echo "Building container image MLBParks:0.0-0"
sh "oc start-build mlbparks --follow --from-file=./target/${project.artifactId} -n ${GUID}-parks-dev"
openshiftTag alias: 'false', destStream: 'MLBParks', destTag: 0.0-0, destinationNamespace: "${GUID}-parks-dev", namespace: "${GUID}-parks-dev", srcStream: 'MLBParks', srcTag: 'latest', verbose: 'false'

echo "Publishing MLBParks to Nexus"
sh "mvn -s ../nexus_settings.xml deploy -DskipTests=true -DaltDeploymentRepository=nexus::default::http://nexus3-${GUID}-nexus.apps.na39.openshift.opentlc.com/repository/releases"

echo "Deploying container image to Development Project"
sh "oc set image dc/mlbparks mlbparks=docker-registry.default.svc:5000/${GUID}-parks-dev/mlbparks:0.0-0 -n ${GUID}-parks-dev"
openshiftDeploy depCfg: 'mlbparks', namespace: "${GUID}-parks-dev", verbose: 'false', waitTime: '', waitUnit: 'sec'

echo "Running integration tests"
curl http://mlbparks-${GUID}-parks-dev.apps.na39.openshift.opentlc.com/ws/data/load/

# To be Implemented by Student
