#!/bin/bash

# Initialize the dev container with proper user setup
set -e

echo "Setting up dev container environment..."

# Force runc runtime for dev container to avoid GPU issues
export DOCKER_RUNTIME="runc"

# Get the username from the environment (passed from VS Code)
USERNAME=${USER:-$(whoami)}
USER_ID=${USER_ID:-$(id -u)}
GROUP_ID=${GROUP_ID:-$(id -g)}

echo "Setting up user: ${USERNAME} (${USER_ID}:${GROUP_ID})"

# Create user if it doesn't exist
if ! id "${USERNAME}" &>/dev/null; then
    echo "Creating user ${USERNAME}..."
    groupadd -g "${GROUP_ID}" "${USERNAME}" || true
    useradd -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash -m "${USERNAME}" || true
    
    # Add user to common groups
    usermod -aG sudo,docker "${USERNAME}" 2>/dev/null || true
    
    # Set up sudo without password for the user
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Set up Python virtual environment if it doesn't exist
if [ ! -d "/app/.venv" ]; then
    echo "Creating virtual environment..."
    cd /app
    uv venv
    uv sync
    chown -R "${USER_ID}:${GROUP_ID}" /app/.venv
fi

# Set up ROS environment
echo "Setting up ROS environment..."
if [ -f "/opt/ros/noetic/setup.bash" ]; then
    echo "source /opt/ros/noetic/setup.bash" >> /home/${USERNAME}/.bashrc
fi

if [ -f "/app/catkin_ws/devel/setup.bash" ]; then
    echo "source /app/catkin_ws/devel/setup.bash" >> /home/${USERNAME}/.bashrc
fi

# Set up Python virtual environment in bashrc
echo "source /app/.venv/bin/activate" >> /home/${USERNAME}/.bashrc

# Set up HSRB environment variables
echo "export HSRB_HOSTNAME=\${HSRB_HOSTNAME:-localhost}" >> /home/${USERNAME}/.bashrc

# Set proper ownership of home directory
chown -R "${USER_ID}:${GROUP_ID}" "/home/${USERNAME}" 2>/dev/null || true

echo "Dev container initialization complete!"

# Keep the container running
tail -f /dev/null
