#!/bin/bash

# Source the ROS environment.
echo "Sourcing the ROS environment from '/opt/ros/noetic/setup.bash'."
source /opt/ros/noetic/setup.bash

# Source the noetic_ws workspace.
echo "Sourcing the Catkin workspace from '/app/noetic_ws/install/setup.bash'."
source /app/noetic_ws/install/setup.bash

# Set bash theme
source /app/docker/scripts/bash-theme-snippet.sh

# Source the Python virtual environment.
source /app/.venv/bin/activate
