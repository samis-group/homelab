#!/bin/bash
# Check if the first two arguments are 'network create'
if [ "$1" = "network" ] && [ "$2" = "create" ]; then
    # If they are, append the additional argument and pass all arguments to the original executable
    "docker-wrapped" "$@" -o "com.docker.network.driver.mtu"=$DOCKER_MTU
else
    # If not, just pass all arguments to the original executable
    "docker-wrapped" "$@"
fi
