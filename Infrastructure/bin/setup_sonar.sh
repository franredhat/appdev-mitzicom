#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up SonarQube in project $GUID-sonarqube"
oc new-app -f https://raw.githubusercontent.com/franredhat/development-homework/master/Infrastructure/templates/sonarqube-postgresql-template.yaml -n $GUID-sonarqube

echo "Setting up SonarQube liveness and readiness probes"
oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok
oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about
# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student
