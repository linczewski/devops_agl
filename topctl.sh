#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

export PROJECT_ROOT=$(dirname "$0")

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
  if podman pod exists agl-build; then
    echo "Pod 'agl-build' already exists. Run 'clean' first, or: podman pod rm -f agl-build"
    return 1
  fi
  podman kube play <(envsubst < pod.yaml)
}

clean() {
  podman pod rm -f agl-build 2>/dev/null || true
}

attach() {
  local containers=($(podman ps --filter "ancestor=agl" --format "{{.Names}}"))
  if [[ ${#containers[@]} -eq 0 ]]; then
    echo "No running containers found for image 'agl'"
    return 1
  fi
  local target
  if [[ ${#containers[@]} -eq 1 ]]; then
    target="${containers[0]}"
  else
    echo "Select a container:"
    select target in "${containers[@]}"; do
      [[ -n $target ]] && break
      echo "Invalid selection"
    done
  fi
  podman exec -it "$target" bash --rcfile ./rcfile.sh
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
  clean)
    clean
    ;;
  attach)
    attach
    ;;
  *)
    echo "Select an option:"
    select opt in init build run attach keys clean quit; do
      case $opt in
        init)   init   ;;
        build)  build  ;;
        run)    run    ;;
        attach) attach ;;
        keys)   keys   ;;
        clean)  clean  ;;
        quit)   exit 0  ;;
        *)     echo "Invalid option $REPLY" ;;
      esac
      echo
      echo "Select an option:"
    done
    ;;
esac
