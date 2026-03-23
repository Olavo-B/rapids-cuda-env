# 🚀 RAPIDS & CUDA Jupyter Workspace

A fully reproducible, GPU-accelerated Docker environment tailored for Data Science, Machine Learning, and custom CUDA C++ development. This setup leverages NVIDIA RAPIDS and provides an out-of-the-box JupyterLab environment with encapsulated local workspace management.

## 📋 Prerequisites

Before running this environment, ensure your host system has the following installed:
* **Docker Engine** (Configured to run without `sudo` via the `docker` group)
* **NVIDIA Drivers** (Appropriate for your GPU)
* **NVIDIA Container Toolkit** (`nvidia-docker2` or `nvidia-container-toolkit`)
* **Git**

## 🛠️ Project Structure

\`\`\`text
.
├── Dockerfile           # Environment definition and build instructions
├── requirements.txt     # Python dependencies (nvcc4jupyter, pandas, etc.)
├── .gitignore           # Prevents committing heavy datasets and compiled binaries
├── .dockerignore        # Optimizes the Docker build context
├── README.md            # Project documentation
└── workspace/           # Bound local directory for persistent notebooks and data
    └── example_project/
\`\`\`

## 📦 1. Git Setup & Repository Management

Initialize the repository and track your configuration files. Avoid committing the contents of the `workspace/` directory if they contain heavy datasets or private models.

\`\`\`bash
git init
git add Dockerfile requirements.txt .gitignore .dockerignore README.md workspace/example_project/
git commit -m "chore: initial commit of RAPIDS/CUDA Docker environment"
\`\`\`

## 🏗️ 2. Building the Docker Image

Build the custom image using the provided `Dockerfile`. 

\`\`\`bash
docker build -t rapids-cuda-custom .
\`\`\`

## 🚀 3. Running the Environment

You have two main ways to run this container. Both methods mount your local `workspace` folder so that all notebooks, `.cu` files, and datasets are saved directly to your host machine.

### Option A: Interactive Mode (Standard)
Best for when you want to see the logs directly in your terminal and shut down the container by pressing `Ctrl+C`.

\`\`\`bash
docker run --name my-rapids-env --gpus all --pull never --rm -it \
    --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
    --user $(id -u):$(id -g) \
    -p 8888:8888 -p 8787:8787 -p 8786:8786 \
    -v "${PWD}/workspace:/home/rapids/notebooks/workspace" \
    rapids-cuda-custom
\`\`\`

### Option B: Detached Mode (Background)
Best for keeping the Jupyter server running in the background while you use your terminal for other Git or host commands.

\`\`\`bash
docker run --name my-rapids-env --gpus all --pull never -d \
    --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
    --user $(id -u):$(id -g) \
    -p 8888:8888 -p 8787:8787 -p 8786:8786 \
    -v "${PWD}/workspace:/home/rapids/notebooks/workspace" \
    rapids-cuda-custom
\`\`\`

## 🔑 4. Accessing JupyterLab

If you ran the container in **Interactive Mode**, the access URL and token will be printed directly in your terminal.

If you ran it in **Detached Mode**, fetch the access link by checking the container logs:

\`\`\`bash
docker logs my-rapids-env
\`\`\`
Look for the URL that starts with `http://127.0.0.1:8888/?token=...` and paste it into your browser.

## 🛑 5. Stopping the Environment

To cleanly shut down the background container and free up your GPU/RAM:

\`\`\`bash
docker stop my-rapids-env
\`\`\`
*(If you ran with the `--rm` flag, the container will automatically be deleted upon stopping. Your `workspace/` files will remain safely on your host machine).*
