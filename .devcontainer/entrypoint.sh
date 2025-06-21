#!/bin/bash

# Dev Container Entry Script
# This script ensures the container is properly set up for VS Code Dev Container usage

set -e

echo "=== HSR Development Environment - Dev Container ==="
echo "Container started at: $(date)"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"

# Source ROS environment if available
if [ -f "/opt/ros/noetic/setup.bash" ]; then
    echo "Sourcing ROS Noetic environment..."
    source /opt/ros/noetic/setup.bash
fi

# Source catkin workspace if available
if [ -f "/app/catkin_ws/devel/setup.bash" ]; then
    echo "Sourcing catkin workspace..."
    source /app/catkin_ws/devel/setup.bash
fi

# Activate Python virtual environment if available
if [ -f "/app/.venv/bin/activate" ]; then
    echo "Activating Python virtual environment..."
    source /app/.venv/bin/activate
fi

echo "=== Environment Setup Complete ==="
echo "Ready for HSR development!"
echo ""

# Execute any command passed to the script, or start an interactive bash shell
if [ $# -eq 0 ]; then
    exec bash -l
else
    exec "$@"
fi
