#!/bin/bash

set -euo pipefail

LAUNCH_DIR=$(pwd); SCRIPT_DIR=$(dirname $0); cd $SCRIPT_DIR; SCRIPT_DIR=$(pwd); cd ..; SCRIPT_PARENT_DIR=$(pwd)

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
QUIET_MODE="--quiet"

init() {
  ./gradlew assemble
}

stopFrontend() {
  if lsof -i:3000 -t &> /dev/null; then
    printf "\n======== Stopping frontend ========\n"
    pkill node || true
  fi
}

startFrontend() {
  cd frontend || exit 1
  stopFrontend

  printf "\n======== Starting frontend ========\n"
  if [[ $1 == "$QUIET_MODE" ]]; then
    echo "Entering quiet mode, output goes here ./scripts/out/frontend_output.log"
    BROWSER=none npm start &> "$ROOT_DIR/scripts/out/frontend_output.log" &
  else
    npm start &
  fi
  cd ..
}

stopBackend() {
  if lsof -i:8080 -t &> /dev/null; then
    printf "\n======== Stopping backend ========\n"
    pkill java || true
  fi
}

startBackend() {
  stopBackend
  printf "\n======== Starting backend ========\n"

  if [[ $1 == "$QUIET_MODE" ]]; then
    echo "Entering quiet mode, output goes here ./scripts/out/backend_output.log"
    ./gradlew :backend:bootRun > "$ROOT_DIR/scripts/out/backend_output.log" &
  else
    ./gradlew :backend:bootRun &
  fi
}

start() {
  mkdir -p "$ROOT_DIR/scripts/out"

  startBackend "$1"
  startFrontend "$1"
}

stop() {
  stopBackend
  stopFrontend
}

testBackend() {
  printf "\n======== Running backend unit tests ========\n"
  ./gradlew :backend:test
}

testE2e() {
  cd e2e || exit 1
  if [[ $1 == "$QUIET_MODE" ]]; then
    npm test
  else
    npm run open
  fi
  cd ..
}

deploy-k8s() {
  echo "Deploying to K8s ..."
  kapp deploy -a animal-rescue -f $SCRIPT_PARENT_DIR/k8s/namespace.yaml,$SCRIPT_PARENT_DIR/backend/k8s/animal-rescue-backend.yaml,$SCRIPT_PARENT_DIR/frontend/k8s/animal-rescue-frontend.yaml --into-ns animal-rescue --diff-changes --yes
}

undeploy-k8s() {
  echo "Undeploying from K8s ..."
  kapp delete -a animal-rescue --yes
}

curl-backend() {
  curl -s http://localhost:8080/animals | jq .
  curl -s http://localhost:8080/hello
  curl -s http://localhost:8080/whoami | jq .
  curl -s http://localhost:8080/actuator/health | jq .
#  curl -X POST -s http://localhost:8080/animals/0/adoption-requests | jq .
}

trap stop SIGINT

case $1 in
init)
  init
  ;;
backend)
  testBackend
  ;;
ci)
  testBackend
  start $QUIET_MODE
  testE2e $QUIET_MODE
#  stop
  ;;
e2e)
  echo 'make sure you have executed the "start" command'
  testE2e "${2:-}"
  ;;
start)
  start "${2:-}"
  if [[ ${2:-} != "$QUIET_MODE" ]]; then
    wait
  fi
  ;;
stop)
  stop
  ;;
deploy)
  deploy-k8s
  ;;
undeploy)
  undeploy-k8s
  ;;
curl-backend)
  curl-backend
  ;;
*)
  echo 'Unknown command. Please specify "init", "backend", "ci", "e2e", "start( --quiet)", or "stop"'
  ;;
esac
