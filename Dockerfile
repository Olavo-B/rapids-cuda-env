# Use the RAPIDS base image with CUDA 13
FROM nvcr.io/nvidia/rapidsai/notebooks:26.02-cuda13-py3.13

# Set the working directory
WORKDIR /home/rapids/notebooks

# Copy requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the local workspace into the container image
COPY workspace/ /home/rapids/notebooks/workspace/

# Set the default directory when the container starts
WORKDIR /home/rapids/notebooks/workspace
