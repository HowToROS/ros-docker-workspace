#!/bin/bash

start_module() {
    # Enable GUI passthorugh
    xhost +

    # Set hostname to current system hostname
    export HOSTNAME

    # Start docker container
    docker compose -f docker-compose-ros-noetic-dev.yaml up -d 
    # docker compose -f docker-compose-ros-noetic-dev.yaml up -d rosmaster &
    # docker compose -f docker-compose-ros-noetic-dev.yaml up -d ros-dev &

}

stop_module() {
    # Set hostname to current system hostname
    export HOSTNAME

    # Start docker container
    docker compose -f docker-compose-ros-noetic-dev.yaml down 
}

restart_module() {
      stop_module
      sleep 5
      start_module
}

build_module() {
    # Set hostname to current system hostname
    export HOSTNAME

    # Build docker container
    docker compose -f docker-compose-ros-noetic-dev.yaml pull 
    docker compose -f docker-compose-ros-noetic-dev.yaml build 
}

usage_message() {

    # Define a file path
    filepath=$0
    
    # Extract the filename and extension from the file path
    filename=$(basename "$filepath")
    echo "Usage: $filename start | stop | restart | build "
}

if [ $# != 1 ]; then                # If Argument is not exactly one
    usage_message

    exit 1                         # Exit the program
fi


ARGUMENT=$(echo "$1" | awk '{print tolower($0)}')     # Converts Argument in lower case. This is to make user Argument case independent. 

if   [[ $ARGUMENT == start ]]; then

    start_module

elif [[ $ARGUMENT == stop ]]; then

    stop_module

elif [[ $ARGUMENT == build ]]; then

    build_module

elif [[ $ARGUMENT == restart ]]; then

    restart_module

else 
    usage_message
fi
