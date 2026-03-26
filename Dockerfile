# Use the RAPIDS base image with CUDA 13
FROM nvcr.io/nvidia/rapidsai/notebooks:26.02-cuda13-py3.13

# Switch to root to install system packages
USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    nvtop \
    nsight-compute \
    && rm -rf /var/lib/apt/lists/*

# REMOVE the CUDA compat folder to force host driver usage
RUN rm -rf /usr/local/cuda/compat

# Switch back to the default rapids user
USER rapids

# Set the working directory
WORKDIR /home/rapids/notebooks

# Copy requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the local workspace into the container image
COPY workspace/ /home/rapids/notebooks/workspace/

# Set the default directory when the container starts
WORKDIR /home/rapids/notebooks/workspace
