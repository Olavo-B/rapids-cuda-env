#!/bin/bash
set -e

echo "Starting Docker and NVIDIA Toolkit installation for Ubuntu..."

# 1. Update the system and install prerequisites
echo "Installing prerequisite packages..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 2. Add Docker's official GPG key and repository
echo "Setting up Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Install Docker Engine
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Create the docker group and add ALL regular users
echo "Configuring the docker group for all users..."
sudo groupadd -f docker

for system_user in $(awk -F':' '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
    sudo usermod -aG docker "$system_user"
    echo " -> Added user: $system_user"
done

# 5. Add NVIDIA Container Toolkit GPG key and repository
echo "Setting up NVIDIA Container Toolkit repository..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 6. Install the NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 7. Configure Docker to use the NVIDIA runtime
echo "Configuring Docker NVIDIA runtime..."
sudo nvidia-ctk runtime configure --runtime=docker

# 8. Restart the Docker daemon
echo "Restarting Docker daemon..."
sudo systemctl restart docker

echo "================================================================="
echo "Installation complete!"
echo "IMPORTANT: Every user must log out and log back in, or run the command:"
echo "    newgrp docker"
echo "in their respective terminals to apply the group permissions."
echo "================================================================="
