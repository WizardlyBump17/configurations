#!/bin/bash

NAME=${1:-comfyui}
CONTAINERFILE=${2:-Containerfile}
COMFYUI_COMMIT=${3:-4d6a058bf1dd18fb6d4594081c3f9a7575c97256}

podman build --tag=$NAME --file=$CONTAINERFILE --build-arg=COMFYUI_COMMIT=$COMFYUI_COMMIT

