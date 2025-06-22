#!/bin/bash

# Script to run a Docker container for HSR development
# Usage: ./RUN-DOCKER-CONTAINER.sh [PROJECT_NAME] [HSR_NUMBER]

set -e

# Change to the directory containing the script
cd "$(dirname "$0")"

USERNAME=$(whoami)

function check_requirements() {
  if [ ! -e keys/authorized_keys ]; then
    echo "ファイルkeys/authorized_keysが存在しないので作成します"
    mkdir -p keys
    touch keys/authorized_keys
  fi

  if [ -z "$OPENAI_API_KEY" ]; then
    read -p "OpenAIのAPI KEYがセットされていません。続行しますか？ (y/N): " yn
    case "$yn" in [yY]*) ;; *)
      echo "export OPENAI_API_KEY=????"
      exit 1
      ;;
    esac
  fi
}

function check_nvidia_runtime() {
  # Check if nvidia-smi command exists and works
  if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    # Check if nvidia docker runtime is available
    if docker info | grep -q "Runtimes.*nvidia"; then
      echo "NVIDIA runtime detected, enabling GPU support."
      export DOCKER_RUNTIME="nvidia"
    else
      echo "NVIDIA driver detected, but Docker NVIDIA runtime not found. Using default runtime."
      export DOCKER_RUNTIME="runc"
    fi
  else
    echo "NVIDIA driver not detected. Using default runtime."
    export DOCKER_RUNTIME="runc"
  fi
}

function setup_project_name() {
  if [ -n "$HSR_PROJECT_NAME" ]; then
    PROJECT="$HSR_PROJECT_NAME"
  elif [ -n "$1" ]; then 
    PROJECT="$1"
  else
    echo "Set HSR_PROJECT_NAME (e.g. 'export HSR_PROJECT_NAME=mytest')"
    exit 1
  fi

  export HSR_PROJECT_NAME="$PROJECT"
  CONTAINER="${PROJECT}_hsr_dev_env_1"
  echo "$0: PROJECT=${PROJECT}"
  echo "$0: CONTAINER=${CONTAINER}"
}

function setup_hsr_hostname() {
  if [ -z "$HSR_NUMBER" ]; then
    read -p "HSRの番号を入力してください (sim, c, c017, 97, 107, ...): " HSR_NUMBER
  fi

  if [ "$HSR_NUMBER" = "c" ]; then
    HSRB_HOSTNAME="hsrc.local"
    CMD="hsrc_mode"
  elif [ "$HSR_NUMBER" = "c017" ]; then
    HSRB_HOSTNAME="hsrc017.local"
    CMD="hsrc017_mode"
  else
    HSRB_HOSTNAME="hsrb${HSR_NUMBER}.local"
    CMD="hsrb${HSR_NUMBER}_mode"
  fi

  # Resolve hostname and export for docker-compose
  echo "Now resolving local host name '${HSRB_HOSTNAME}'..."
  HSRB_IP=$(avahi-resolve -4 --name "${HSRB_HOSTNAME}" 2>/dev/null | cut -f 2 || true)

  if ! command -v avahi-resolve &>/dev/null; then
    echo "Failed to execute 'avahi-resolve'. You may need to install 'avahi-utils'."
    HSRB_IP="127.0.0.1"
  elif [ -n "${HSRB_IP}" ]; then
    echo "Successfully resolved host name '${HSRB_HOSTNAME}' as '${HSRB_IP}'"
  else
    echo "Failed to resolve host name '${HSRB_HOSTNAME}': Using localhost."
    HSRB_IP="127.0.0.1"
  fi

  # Export variables for docker-compose
  export HSRB_HOSTNAME="${HSRB_HOSTNAME}"
  export HSRB_IP="${HSRB_IP}"
  
  echo "Exported HSRB_HOSTNAME=${HSRB_HOSTNAME}"
  echo "Exported HSRB_IP=${HSRB_IP}"
}

function run_docker_container() {
  # Check if container already exists
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER}$" || [ $? -eq 1 ]; then
    # Container exists if grep returned 0, doesn't exist if grep returned 1
    if [ "$(docker ps -a --format '{{.Names}}' | grep -E "^${CONTAINER}$" || true)" ]; then
      echo "Container '${CONTAINER}' already exists."
      echo "Starting the existing container..."
      docker start "${CONTAINER}" || {
        echo "Failed to start container. Removing and recreating..."
        docker rm "${CONTAINER}" || true
        docker compose --compatibility -p "${PROJECT}" --build-args HSRB_HOSTNAME=${HSRB_HOSTNAME} HSRB_IP=${HSRB_IP} -f ./docker/docker-compose.yml up -d --build
      }
    else
      echo "Container '${CONTAINER}' does not exist."
      echo "Creating a new container..."
      docker compose --compatibility -p "${PROJECT}" -build-args HSRB_HOSTNAME=${HSRB_HOSTNAME} HSRB_IP=${HSRB_IP} -f ./docker/docker-compose.yml up -d
    fi
  fi
}

function update_container_hosts() {
  echo "Setting HSRB_HOSTNAME environment variable in container..."
  docker exec -i "${CONTAINER}" bash -c "
sed -i '/HSRB_HOSTNAME=/c\\HSRB_HOSTNAME=${HSRB_HOSTNAME}' ~/.bashrc
"
}

function setup_x11_auth() {
  if [ -n "$DISPLAY" ]; then
    XAUTH_RESULT="$(xauth list "$DISPLAY" 2>/dev/null || true)"
    if [ -z "$XAUTH_RESULT" ]; then
      xauth generate "$DISPLAY" . 2>/dev/null || true
    fi

    if XAUTH_LIST=$(xauth list "$DISPLAY" 2>/dev/null || true) && [ -n "$XAUTH_LIST" ]; then
      read -r _ XAUTH_PROTOCOL XAUTH_KEY <<<"$XAUTH_LIST"
      docker exec -it "$CONTAINER" bash -c "touch /root/.Xauthority; xauth add $DISPLAY $XAUTH_PROTOCOL $XAUTH_KEY" || true
    else
      echo "Warning: Could not set up X11 authentication. GUI applications may not work."
    fi
  fi
}

function enter_container() {
  local option="$1"

  case "$option" in
  "")
    # Use -l flag to ensure .bashrc is sourced in bash
    docker exec -e DISPLAY="$DISPLAY" -i -t -u "${USERNAME}" "${CONTAINER}" bash -l
    ;;
  # Other cases...
  *)
    docker exec -e DISPLAY="$DISPLAY" -i -t -u "${USERNAME}" "${CONTAINER}" bash -l
    ;;
  esac
}

echo "Starting Docker container for HSR development..."
setup_project_name "$@"

echo "Setting up HSR hostname..."
setup_hsr_hostname

echo "Checking requirements..."
check_requirements

echo "Checking NVIDIA runtime..."
check_nvidia_runtime

echo "Running Docker container..."
run_docker_container

echo "Updating container hosts..."
update_container_hosts

echo "Setting up X11 authentication..."
setup_x11_auth

# echo "Entering the container..."
# enter_container "$2"
