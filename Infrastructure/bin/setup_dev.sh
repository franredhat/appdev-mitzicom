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

echo "Creating MLBParks base app"
oc new-build --binary=true --name="mlbparks" jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev
oc new-app ${GUID}-parks-dev/mlbparks:0.0-0 --name=mlbparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
oc set triggers dc/mlbparks --remove-all -n ${GUID}-parks-dev
oc expose dc mlbparks --port 8080 -n ${GUID}-tasks-dev
oc expose svc mlbparks -n ${GUID}-tasks-dev

echo "Creating Nationalparks base app"
oc new-build --binary=true --name="nationalparks" redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
oc new-app ${GUID}-parks-dev/nationalparks:0.0-0 --name=nationalparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
oc set triggers dc/nationalparks --remove-all -n ${GUID}-parks-dev
oc expose dc nationalparks -n ${GUID}-parks-dev
oc expose svc nationalparks -n ${GUID}-tasks-dev

echo "Creating ParksMap base app"
oc new-build --binary=true --name="parksmap" redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
oc new-app ${GUID}-parks-dev/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
oc set triggers dc/parksmap --remove-all -n ${GUID}-parks-dev
oc expose dc parksmap -n ${GUID}-parks-dev
oc expose svc parksmap -n ${GUID}-parks-dev
oc policy add-role-to-user view --serviceaccount=default -n ${GUID}-parks-dev
