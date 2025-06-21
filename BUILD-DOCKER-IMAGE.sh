#!/bin/bash

# Script to build Docker images for HSR development environment
# This first builds the base image and then the development environment image

set -eu

SKIP_BASE_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-base)
      SKIP_BASE_BUILD=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "Starting Docker image build process..."

# Get user ID and group ID for container user permissions
USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [ "$SKIP_BASE_BUILD" = false ]; then
  # Build the base HSR image with ROS Noetic
  echo "Building base HSR image with ROS Noetic..."
  docker buildx build \
    --platform linux/amd64 \
    --cache-from type=local,src=./.cache/noetic_hsr:latest-cache \
    --cache-to type=local,dest=./.cache/noetic_hsr:latest-cache \
    --build-arg nvidia_cuda_version=11.8.0-devel-ubuntu20.04 \
    -t weblab/hsr:v2-noetic \
    -f ./docker/Dockerfile.noetic_hsr \
    --load \
    .
else
  echo "Skipping base HSR image build (--skip-base flag set)."
fi

# Build the development environment image
echo "Building HSR development environment image..."
docker buildx build \
  --platform linux/amd64 \
  --cache-from type=local,src=./.cache/hsr_env:latest-cache \
  --cache-to type=local,dest=./.cache/hsr_env:latest-cache \
  --build-arg USER_ID="${USER_ID}" \
  --build-arg GROUP_ID="${GROUP_ID}" \
  --build-arg USERNAME="$(whoami)" \
  -t weblab/hsr_env:latest \
  -f ./docker/Dockerfile \
  --load \
  .

echo "Docker image build completed successfully!"
echo "Images built:"
if [ "$SKIP_BASE_BUILD" = false ]; then
  echo "  - weblab/hsr:v2-noetic"
fi
echo "  - weblab/hsr_env:latest"