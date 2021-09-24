#!/bin/bash

# set -x

LAUNCH_DIR=$(pwd); SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; cd $SCRIPT_DIR; cd ..; SCRIPT_PARENT_DIR=$(pwd);
. $SCRIPT_DIR/set-env.sh

cd $SCRIPT_PARENT_DIR

kapp deploy -a $NS_CONTOUR -f https://projectcontour.io/quickstart/contour.yaml,$SCRIPT_PARENT_DIR/k8s/contour-ns.yaml --into-ns $NS_CONTOUR --diff-changes --yes

kubectl -n $NS_CONTOUR get pods -l "app=contour"
kubectl get service envoy -n $NS_CONTOUR -o wide

kapp inspect -a $NS_CONTOUR  --tree

cd $LAUNCH_DIR