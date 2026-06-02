#!/usr/bin/env bash

PROJECT_ROOT=$(dirname "$0")

init() {
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
}

keys() {
  ssh-add -l
}

build() {
  podman build --progress=plain --ssh=default -t agl .
}

run() {
  podman kube play <(envsubst < pod.yaml)
}

case "${1:-}" in
  init)
    init
    ;;
  build)
    build
    ;;
  keys)
    keys
    ;;
  run)
    run
    ;;
  *)
    echo "Select an option:"
    select opt in init build run keys quit; do
      case $opt in
        init)  init  ;;
        build) build ;;
        run)   run   ;;
        keys)  keys  ;;
        quit)  exit 0 ;;
        *)     echo "Invalid option $REPLY" ;;
      esac
      echo
      echo "Select an option:"
    done
    ;;
esac
