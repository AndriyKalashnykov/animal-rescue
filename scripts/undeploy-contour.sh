#!/bin/bash

# set -x

LAUNCH_DIR=$(pwd); SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; cd $SCRIPT_DIR; cd ..; SCRIPT_PARENT_DIR=$(pwd);
. $SCRIPT_DIR/set-env.sh

cd $SCRIPT_PARENT_DIR

kapp delete -a $NS_CONTOUR --yes

kubectl get cm,secret,deploy,pod,svc,ingress -n $NS_CONTOUR

cd $LAUNCH_DIR