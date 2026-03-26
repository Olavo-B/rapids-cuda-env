#!/bin/bash

# ==========================================
# Configuration Variables
# ==========================================
IMAGE_NAME="rapids-cuda-custom"
CONTAINER_NAME="my-rapids-env"
WORKSPACE_DIR="${PWD}/workspace"

# ==========================================
# Prerequisite Checks
# ==========================================
echo "🔍 Checking system dependencies..."

# 1. Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# 2. Check if Docker daemon is running and accessible
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker daemon is not running, or your user does not have permission."
    echo "💡 Fix: Start the Docker service, or ensure your user is in the 'docker' group."
    exit 1
fi

# 3. Check for NVIDIA Host Drivers
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ Error: 'nvidia-smi' not found. Ensure NVIDIA drivers are installed on the host."
    exit 1
fi

# 4. Check for NVIDIA Container Toolkit integration in Docker
if ! docker info | grep -i "Runtimes" | grep -q "nvidia"; then
    echo "❌ Error: NVIDIA Container Toolkit is not configured in Docker."
    echo "💡 Fix: Install the nvidia-container-toolkit and restart the Docker daemon."
    exit 1
fi

echo "✅ All dependencies met! GPU access is configured."
echo "---------------------------------------------------"

# ==========================================
# Build & Run Process
# ==========================================

# Ensure the local workspace directory exists to prevent root ownership issues
mkdir -p "$WORKSPACE_DIR"

echo "🔨 Step 1: Building the Docker image ($IMAGE_NAME)..."
docker build -t "$IMAGE_NAME" .

echo "🚀 Step 2: Starting the Jupyter environment..."
# Stop and remove the container if it's already running to avoid conflicts
docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker rm "$CONTAINER_NAME" >/dev/null 2>&1

# Run the container in detached mode (-d)
docker run --name "$CONTAINER_NAME" --gpus all --pull never -d \
    --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
    --user $(id -u):$(id -g) \
    -p 8888:8888 -p 8787:8787 -p 8786:8786 \
    -v "$WORKSPACE_DIR:/home/rapids/notebooks/workspace" \
    "$IMAGE_NAME"

echo "------------------------------------------------------------------"
echo "✅ Waiting for JupyterLab to start..."
sleep 3  

# This regex captures "http://127.0.0.1:8888" and any trailing paths or tokens
JUPYTER_URL=$(docker logs "$CONTAINER_NAME" 2>&1 | grep -m 1 -oE "http://127\.0\.0\.1:8888[a-zA-Z0-9/=?&-]*")

if [ -n "$JUPYTER_URL" ]; then
    echo "Access your JupyterLab environment here:"
    echo "$JUPYTER_URL"
else
    echo "Error: Could not find the Jupyter URL. Check the container logs manually:"
    echo "docker logs $CONTAINER_NAME"
fi
echo "------------------------------------------------------------------"
echo "To stop the environment later, run: docker stop $CONTAINER_NAME"
