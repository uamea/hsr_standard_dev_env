#!/bin/bash

# Script to build Docker images for HSR development environment
# This first builds the base image and then the development environment image

set -eu

echo "Starting Docker image build process..."

# Get user ID and group ID for container user permissions
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Build the base HSR image with ROS Noetic
echo "Building base HSR image with ROS Noetic..."
docker buildx build \
  --platform linux/amd64 \
  --cache-from type=registry,ref=weblab/hsr:v2-noetic-cache \
  --cache-to type=inline \
  --build-arg nvidia_cuda_version=11.8.0-devel-ubuntu20.04 \
  -t weblab/hsr:v2-noetic \
  -f ./docker/Dockerfile.noetic_hsr \
  --load \
  .

# Build the development environment image
echo "Building HSR development environment image..."
docker buildx build \
  --platform linux/amd64 \
  --cache-from type=registry,ref=weblab/hsr_env:latest-cache \
  --cache-to type=inline \
  --build-arg USER_ID="${USER_ID}" \
  --build-arg GROUP_ID="${GROUP_ID}" \
  --build-arg USERNAME="$(whoami)" \
  -t weblab/hsr_env:latest \
  -f ./docker/Dockerfile \
  --load \
  .

echo "Docker image build completed successfully!"
echo "Images built:"
echo "  - weblab/hsr:v2-noetic"
echo "  - weblab/hsr_env:latest"