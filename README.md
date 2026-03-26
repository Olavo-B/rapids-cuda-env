# 🚀 RAPIDS & CUDA Jupyter Workspace

A streamlined, GPU-accelerated Docker environment for Data Science, Machine Learning, and custom CUDA C++ development using NVIDIA RAPIDS.

> [!NOTE]
> Your local `workspace/` directory is automatically mounted. All notebooks, datasets, and `.cu` files saved there will persistently remain on your host machine even after the container is destroyed.

## 📋 Prerequisites

> [!IMPORTANT]
> Ensure your host system is fully configured for GPU passthrough before starting.
* **Docker Engine** (Configured to run without `sudo`)
* **NVIDIA Drivers** (Compatible with your hardware)
* **NVIDIA Container Toolkit** (`nvidia-ctk` properly bridged to Docker)

## 🛠️ Project Structure

```text
.
├── Dockerfile           # GPU environment definition
├── requirements.txt     # Python dependencies
├── start_env.sh         # One-click startup and token extraction script
└── workspace/           # Persistent local directory for notebooks/data
```

## 🚀 Quick Start (Recommended)

> [!TIP]
> Use the provided startup script to automate the workflow. It handles building the image, launching the container in the background, and fetching your secure Jupyter access URL automatically.

Make the script executable and run it:

```bash
chmod +x start_env.sh
./start_env.sh
```

*The script will automatically print the exact `http://127.0.0.1:8888/...` URL for you to paste into your browser.*

## 🏗️ Manual Docker Management

If you prefer to manage the container lifecycle manually instead of using the script:

**1. Build the Image:**
```bash
docker build -t rapids-cuda-custom .
```

**2. Run the Container:**
```bash
docker run --name my-rapids-env --gpus all --cap-add=SYS_ADMIN --rm -it \
    -p 8888:8888 -v "${PWD}/workspace:/home/rapids/notebooks/workspace" \
    rapids-cuda-custom
```

> [!WARNING]
> The `--cap-add=SYS_ADMIN` flag is strictly required if you intend to use NVIDIA Nsight Compute (`ncu`) to profile your custom CUDA kernels. 

**3. Stop the Environment:**
\`\`\`bash
docker stop my-rapids-env
\`\`\`

> [!CAUTION]
> Avoid committing heavy datasets or compiled binaries inside the `workspace/` folder to version control. Ensure your `.gitignore` is properly configured to keep your repository lightweight.
