#!/bin/bash

# Environment detection script for dev container
# This script helps choose the right configuration based on the system

detect_wsl() {
    if [[ -f /proc/version ]] && grep -q "Microsoft\|WSL" /proc/version; then
        return 0  # WSL detected
    fi
    return 1  # Not WSL
}

detect_nvidia() {
    if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null 2>&1; then
        return 0  # NVIDIA detected
    fi
    return 1  # No NVIDIA
}

main() {
    echo "Detecting environment..."
    
    if detect_wsl; then
        echo "WSL environment detected"
        export DOCKER_RUNTIME="runc"
        echo "Using default runtime to avoid WSL GPU issues"
    elif detect_nvidia; then
        echo "NVIDIA GPU detected"
        if docker info 2>/dev/null | grep -q "Runtimes.*nvidia"; then
            echo "NVIDIA Docker runtime available"
            export DOCKER_RUNTIME="nvidia"
        else
            echo "NVIDIA GPU found but Docker runtime not available"
            export DOCKER_RUNTIME="runc"
        fi
    else
        echo "No special GPU configuration needed"
        export DOCKER_RUNTIME="runc"
    fi
    
    echo "Environment detection complete. Runtime: ${DOCKER_RUNTIME}"
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
