# HSR Standard Development Environment
This repository contains a template for the modern HSR standard development environment using uv. 

## Quick Start

### Option 1: VS Code Dev Container (Recommended)
The easiest way to get started is using VS Code with the Dev Container extension:

1. Open this repository in VS Code
2. Install the "Dev Containers" extension if not already installed
3. When prompted, click "Reopen in Container" or use `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
4. VS Code will automatically set up the complete development environment

### Option 2: Manual Docker Setup
If you prefer to run the container manually:

```bash
# Set your project name
export HSR_PROJECT_NAME=myproject

# Run the container (replace 'c' with your HSR number if applicable)
./RUN-DOCKER-CONTAINER.sh c
```

## Overview



## Features

### VS Code Dev Container Integration
- **One-click setup**: Automatically configures the complete development environment
- **Pre-installed extensions**: Includes Python, ROS, C++, Git, and Japanese language support
- **User synchronization**: Creates a user in the container matching your local username
- **X11 forwarding**: Supports GUI applications through X11 forwarding
- **Integrated terminal**: Pre-configured with ROS and Python environments

### Pretty-looking Terminal


### Rapid image build


### Well-managed development environment




