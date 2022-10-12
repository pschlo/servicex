#!/bin/bash


# create docker network if not exist
if ! [[ $(docker network ls --filter name="$DOCKER_NET" | tail -n +2) ]]; then
    docker network create "$DOCKER_NET"
fi
