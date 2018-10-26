#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT=${PROJECT:=cdi-techday}
APP_NAME=${APP_NAME:=consumer}
#APP_VOLUME=$PWD/$APP_NAME
echo $DIR

echo "Creating Minishift-Demo"
echo "=========================="
echo "(1/4) Applying extra permissions"
# This adds anyuid and hostaccess security context constraints to default service account
# This is acceptable for a dev environment only
oc login -u system:admin
oc adm policy add-scc-to-user anyuid system:serviceaccount:$PROJECT:default
oc adm policy add-scc-to-user hostaccess system:serviceaccount:$PROJECT:default
echo "developer" | oc login -u developer
echo "=========================="
echo "(2/4) Creating new project"

oc new-project $PROJECT \
  --display-name="CDI Techday Project" \
  --description="Project for CDI Techday 11/18" \
  > /dev/null
oc project $PROJECT

echo "=========================="
echo "(3/4) Configure Build, ImageStream, Service and Route"
# This passes in values to our template for each of the parameters defined
# ${NAME} becomes hello-server in those configs
oc process -f "$DIR"/oc/oc.yaml \
  -p NAMESPACE=$PROJECT \
  -p NAME=$APP_NAME \
  -p PROBE=/actuator/health \
  -p SERVER_PORT=8181 \
  -p LOG_LEVEL=debug | oc create -f - 

#echo "==========================" 
#echo "(4/4) Deploying hello-server Pod"
oc rollout latest dc/$APP_NAME
oc rollout status dc/$APP_NAME

