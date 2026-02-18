#!/bin/bash

NAME=${1:-llama.cpp-ipex}
CONTAINER_FILE=${2:-Containerfile}

podman build --file="$CONTAINER_FILE" --tag="$NAME"

