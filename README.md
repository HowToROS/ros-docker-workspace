# ROS Docker Development Environment

This repository provides a step-by-step guide to set up a ROS development environment within a Docker container on your local computer. Using Docker ensures a consistent and isolated environment for your ROS projects, and integrating it with Visual Studio Code (VSCode) enhances your development experience.

This repository is for ROS Noetic. For ROS2 Docker development environment see this repository: [ros2-docker-workspace](https://github.com/niladut/ros2-docker-workspace)

## Prerequisites

Before you begin, make sure you have the following prerequisites:

1. **OS:** Ubuntu is recommended).
2. **Docker** installed on your system. Installation instructions on the official website: [Install Docker](https://docs.docker.com/get-docker/).
3. **VSCode** installed on your system. Installation instructions on the official website:  [Install VSCode](https://code.visualstudio.com/Download)

## Steps

Follow these steps to set up the ROS development environment:

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/niladut/ros-docker-workspace.git
cd ros-docker-workspace
```

### 2. Docker Compose Configuration
The Docker Compose configuration  file `docker-compose-ros-noetic-dev.yml` creates a ROS development environment in a Docker container with network and device access, allowing for efficient development and debugging.

`docker-compose-ros-noetic-dev.yml` :

```yaml
version: "3.7"

x-env-file-common-variables: &env_file
    config/ros1/${HOSTNAME}.env

services:

  ros1-dev:
    container_name: ros1-dev
    image: ros1-dev:nvidia-noetic
    network_mode: host
    ipc: host # TODO: Investigate  issue
    build:
      context: .
      dockerfile: Dockerfile.nvidia-ros1-noetic
      network: host
    environment:
      - "DISPLAY"
      - "NVIDIA_VISIBLE_DEVICES=all"
      - "NVIDIA_DRIVER_CAPABILITIES=all"
      # - "ROS_DOMAIN_ID=25" # Optional: to choose ROS domain
      # - "ROS_LOCALHOST_ONLY=0" # Optional: set to 1 if you want to present network communication
    env_file: *env_file
    privileged: true
    restart: unless-stopped
    # command: bash -c "sleep 3; source "
    command: tail -f /dev/null
    volumes:
      - type: bind
        source: /dev
        target: /dev
      - $HOME/logs/docker/ros1:/root/.ros/
      - $HOME/user/ros1_ws:/root/ros1_ws
      - $HOME/user/docker_ws:/root/docker_ws
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      - $HOME/.Xauthority:/root/.Xauthority:rw
      - /var/run/dbus:/var/run/dbus
      - $HOME/.ssh:/root/.ssh
```


#### 2.1 Sharing Folders with the Docker container
Sharing the access to folders on the host system to the docker container can be done by binding the paths for these folders with a path inside the docker container. This is done by configuring the `volumes` section of the docker container service:
```yaml
volumes:
- type: bind
source: /dev
target: /dev
- /tmp/.X11-unix:/tmp/.X11-unix:rw
- $HOME/.Xauthority:/root/.Xauthority:rw
- /var/run/dbus:/var/run/dbus
- $HOME/.ssh:/root/.ssh
- $HOME/logs/docker/ros1:/root/.ros/
- $HOME/ros1_ws:/root/ros1_ws
- $HOME/docker_ws:/root/docker_ws
```
The configuration assumes certain directory structures (`$HOME/logs/docker/ros1`, `$HOME/ros1_ws`, etc.). You can add your custom folder paths in by adding a new entry under the `volumes` section:
```yaml
volumes:
.
.
.
      - <absolute-path-to-directory-on-host>:<absolute-path-to-directory-in-docker-container>
```
This configuration sets up a service named `ros1_container` using the Docker image built from the provided `Dockerfile`. It also mounts a local `workspace` directory into the container, allowing file sharing between the host and the container.


#### 2.2 Environment Variable Configuration
The project defines the system and ROS environemnt variables required in the docker container in the following sections:
- `environment` : Sets environment variables for the container, including "DISPLAY", "NVIDIA_VISIBLE_DEVICES", and "NVIDIA_DRIVER_CAPABILITIES".
- `env_file`: Loads environment variables from the common environment file `config/ros1/${HOSTNAME}.env`.

To create a custom environment variable configuration file for the current host system with (`$HOSTNAME`), make a duplicate of the default environment configuration file (`config/ros1/localhost.env`) and place it at `config/ros1/${HOSTNAME}.env`. 

For example, if the system hostname is `mypc`, then follow the following commands:
```bash
cd config/ros1/
cp localhost.env mypc.env
```

The environment variable `${HOSTNAME}` is usually set to the hostname of the current system (in Ubuntu). If it is not defined, and if the current system hostname is `mypc`, it can define by:
```bash
export HOSTNAME=mypc
```

### 3. Using the Bash Script

The provided Bash script simplifies the management of your ROS Docker development environment. It offers commands to start, stop, restart, or build the environment using Docker Compose. The scipt will work on Ubuntu and OSX operating systems. If you are on Windows, you can refer to the docker commands in the `ros1_docker.sh` bash scipt file.


Here's how to use the `ros1_docker.sh` script on Ubuntu or OSX:

#### 3.1. Setting Up Environment Variables:
    
The script uses an environment configuration file located in `config/ros1/${HOSTNAME}.env` to set up environment variables. You can create this file and define environment variables as needed for your ROS environment. 
    
#### 3.2. Understanding the Commands:
    
The script supports the following commands:

- `start`: Starts the ROS Docker environment by executing the specified Docker Compose file.
- `stop`: Stops and removes the Docker containers defined in the Docker Compose file.
- `restart`: Stops, rebuilds, and restarts the Docker containers.
- `build`: Builds the Docker containers defined in the Docker Compose file.
#### 3.3. Running the Script:
    
Open a terminal and navigate to the directory where the script is located. Then, use the following syntax to execute the script with a specific command:

```bash
./ros1_docker.sh command

```

Replace `command` with one of the commands mentioned above (e.g., `start`, `stop`, `restart`, `build`).

**Example:**

To start the ROS Docker environment, execute:

```bash
./ros1_docker.sh start
```

To stop the environment, execute:

```bash
./ros1_docker.sh stop
```

To rebuild and restart the environment, execute:

```bash
./ros1_docker_script.sh restart
```

To build the Docker containers, execute:

```bash
./ros1_docker_script.sh build
```

If you're unsure about the available commands, running the script without any arguments will display a usage message:

```bash
./ros1_docker_script.sh
```

This will provide information about using the script and the available commands.

The provided script helps you manage your ROS Docker development environment with ease, automating various Docker-related tasks and allowing you to focus on your robotics projects.



### 4. Set Up Development Environment with VSCode

Setting Up a Development Environment with VSCode and Docker for ROS

#### Step 4.1: Install the "Dev Containers" Extension

Begin by installing the "Dev Containers" extension in VSCode.

#### Step 4.2: Open Project in VSCode

1. Launch VSCode and open your project directory.
2. After starting the Docker container (as described earlier), press `Ctrl` + `Shift` + `P` (or `Cmd` + `Shift` + `P` on macOS).
3. Type "Dev Containers: Attach to running container" and select the running container.
4. VSCode will open a new window within the container, providing a seamless development environment.

#### Step 4.3: Open ROS2 Workspace

1. In the new window, navigate to **"File > Open Folder..."**.
2. Choose the `/root/ros1_ws` folder inside the container to open.

#### Step 4.4: Edit Files

1. Use the left sidebar file explorer to select and edit files for development.
2. Changes made in the `/root/ros1_ws` folder of the VSCode Dev Container environment will be saved directly to the local host system, persisting even when the container is stopped.

For more detailed information, refer to the [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers) guide.


## Command Line for the Docker Container

Open a shell terminal linked to the Docker container:

1. Navigate to **"Terminal > New Terminal"** in VSCode.
2. A shell terminal will open for executing commands within the ROS2 docker container.
   
  
You can also link any shell terminal on the host system to the Docker container using the following command (on Ubuntu):

```
docker exec -it ros1-dev bash
```


## Graphical Applications with Docker

Running the script with the start argument lets you run GUI applications like gazebo or rviz2 from any shell terminal linked to the ros1-dev Docker container. (Tested on Ubuntu.)


## Feedback

Feel free to explore advanced features like hardware device access, using ROS packages, and further customization within the Docker environment.
Also feel free to suggest improvements and features by creating [issues](https://github.com/niladut/ros-docker-workspace/issues) or posting in the [discussions](https://github.com/niladut/ros-docker-workspace/discussions).

## Additional Referneces and Links

- [VSCode, Docker, and ROS2 -- by Allison Thackston](https://www.allisonthackston.com/articles/vscode-docker-ros2.html)
- [A Guide to Docker and ROS -- by Robotic Sea Bass](https://roboticseabass.com/2021/04/21/docker-and-ros/)


## Author

This ROS Docker Workspace guide was authored by [Niladri Dutta](https://github.com/niladut).

Happy coding! 🤖🐍🐬
