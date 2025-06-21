# HSR Development Environment - Dev Container

This directory contains the VS Code Dev Container configuration for the HSR development environment.

## Features

- Automatically starts the HSR Docker container using `RUN-DOCKER-CONTAINER.sh`
- Creates a user inside the container matching your local username
- Pre-configured with essential extensions for ROS, Python, C++, and Git development
- Integrated with the existing Docker Compose setup

## Extensions Included

- **Japanese Language Pack** - Japanese language support for VS Code
- **Python** - Python language support with debugging
- **ROS** - ROS development tools and syntax highlighting
- **C++** - C++ IntelliSense and debugging support
- **GitLens** - Enhanced Git capabilities
- **Git History** - View Git history and file changes
- **Git Graph** - Visual Git graph
- **autoDocstring** - Automatic Python docstring generation
- **isort** - Python import sorting
- **Path Intellisense** - Auto-completion for file paths
- **Error Lens** - Inline error and warning highlights
- **Black Formatter** - Python code formatting
- **mypy** - Python static type checking

## Usage

1. Open this workspace in VS Code
2. When prompted, click "Reopen in Container" or use the Command Palette:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Dev Containers: Reopen in Container"
   - Select the command

3. VS Code will automatically:
   - Run the `RUN-DOCKER-CONTAINER.sh` script with project name "devcontainer"
   - Start the Docker container
   - Set up the development environment
   - Install all the configured extensions

## Environment Variables

The dev container respects the following environment variables:
- `OPENAI_API_KEY` - Your OpenAI API key (if needed)
- `DISPLAY` - X11 display for GUI applications
- `HSR_PROJECT_NAME` - Set to "devcontainer" automatically

## Python Environment

The container automatically sets up a Python virtual environment at `/app/.venv` and activates it in the terminal. All Python tools (Black, isort, mypy) are configured to use this environment.

## ROS Environment

The ROS Noetic environment is automatically sourced, and C++ IntelliSense is configured with ROS include paths.

## Troubleshooting

If you encounter issues:

1. **Container fails to start**: Check that Docker is running and you have the necessary permissions

2. **NVIDIA/GPU runtime errors in WSL**: The dev container automatically uses the default `runc` runtime instead of `nvidia` to avoid WSL GPU compatibility issues. If you need GPU support, use the manual container setup with `RUN-DOCKER-CONTAINER.sh`

3. **X11 forwarding issues**: Ensure `DISPLAY` environment variable is set correctly. On WSL, you may need to:
   ```bash
   export DISPLAY=:0
   # or use WSLg
   export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
   ```

4. **Permission issues**: The container automatically creates a user matching your local user ID

5. **Extensions not working**: Try reloading the window or rebuilding the container

## Manual Container Management

You can still use the original `RUN-DOCKER-CONTAINER.sh` script directly if needed:

```bash
# Set project name
export HSR_PROJECT_NAME=myproject

# Run container
./RUN-DOCKER-CONTAINER.sh [HSR_NUMBER]
```
