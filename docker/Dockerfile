FROM weblab/hsr:v2-noetic
# Install common optional packages/tools.
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y --no-install-recommends \
  git \
  vim \
  inetutils-ping \
  iproute2 \
  mesa-utils \
  net-tools \
  openssh-client \
  openssh-server \
  zip \
  unzip \
  python3-tk \
  # ros-noetic-ros-numpy \
  libfcl-dev \
  libpcl-dev \
  python3-pcl \
  terminator \
  fonts-takao \
  x11vnc xvfb fluxbox # for VNC \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install the latest version of ros_numpy (to catch up with the latest changes regarding numpy)
WORKDIR /external_modules/
RUN git clone https://github.com/eric-wieser/ros_numpy.git && \
  cp -r ros_numpy/src/ros_numpy/ /opt/ros/noetic/lib/python3/dist-packages/

WORKDIR /app

# Copy the scripts to the container
COPY ./docker/scripts/ /app/docker/scripts/
RUN chmod +x /app/docker/scripts/*.sh

# Create a non-root user that matches the host user
ARG USER_ID
ARG GROUP_ID
ARG USERNAME=trail

# Create group first, handle existing group
RUN getent group ${GROUP_ID} >/dev/null 2>&1 || groupadd -g ${GROUP_ID} ${USERNAME}

# Create user, handle existing user
RUN if ! getent passwd ${USER_ID} >/dev/null 2>&1; then \
        useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash ${USERNAME}; \
    else \
        existing_user=$(getent passwd ${USER_ID} | cut -d: -f1); \
        usermod -l ${USERNAME} -d /home/${USERNAME} -m $existing_user 2>/dev/null || true; \
    fi

# Add user to sudoers
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up directories with proper permissions (minimal chown)
RUN mkdir -p /home/${USERNAME}/.local/share && \
    chown -R ${USER_ID}:${GROUP_ID} /home/${USERNAME} && \
    chown ${USER_ID}:${GROUP_ID} /app && \
    chmod +x /app/docker/scripts/*.sh

# Switch to non-root user
USER ${USERNAME}

# Setup user-specific configurations
RUN echo 'source /app/docker/scripts/initialize-bash-script.sh' >> ~/.bashrc

# Setup uv for the user
COPY --chown=${USER_ID}:${GROUP_ID} ./pyproject.toml uv.lock .python-version /app/

RUN uv python install 3.10 && \
    uv python pin 3.10 && \
    uv venv

# Overwrite the entry point of the parent image
ENTRYPOINT []

# Enter the container with a Bash shell
CMD ["/bin/bash"]