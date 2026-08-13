#!/bin/sh

LOCAL_CODE="${1:-/tmp/maki-code/}"
IMAGE="${2:-localhost/maki:latest}"
CONFIG_DIRECTORY="${3:-$(pwd)/config/}"

mkdir "$LOCAL_CODE"
podman run --interactive --tty --volume="$LOCAL_CODE:/code/" --volume="$CONFIG_DIRECTORY/providers.toml:/root/.config/maki/providers.toml" --volume="$CONFIG_DIRECTORY/model:/root/.local/state/maki/model" "$IMAGE" --yolo
