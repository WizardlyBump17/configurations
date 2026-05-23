#!/usr/bin/env bash
set -e

# Optional --device / -d
if [[ "$1" == "--device" || "$1" == "-d" ]]; then
    if [[ -z "$2" ]]; then
        echo "Error: --device requires a value"
        exit 1
    fi

    export ONEAPI_DEVICE_SELECTOR="$2"

    # Remove --device and its value from args
    shift 2
else
    export ONEAPI_DEVICE_SELECTOR="level_zero:0"
fi

export ZES_ENABLE_SYSMAN=1
export SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1

# Read the first command argument
arg1="$1"

# Shift the arguments to remove the command
shift

if [[ "$arg1" == '--convert' || "$arg1" == '-c' ]]; then
    exec python3 ./convert_hf_to_gguf.py "$@"

elif [[ "$arg1" == '--quantize' || "$arg1" == '-q' ]]; then
    exec ./llama-quantize "$@"

elif [[ "$arg1" == '--run' || "$arg1" == '-r' ]]; then
    exec ./llama-cli "$@"

elif [[ "$arg1" == '--bench' || "$arg1" == '-b' ]]; then
    exec ./llama-bench "$@"

elif [[ "$arg1" == '--perplexity' || "$arg1" == '-p' ]]; then
    exec ./llama-perplexity "$@"

elif [[ "$arg1" == '--all-in-one' || "$arg1" == '-a' ]]; then
    echo "Converting PTH to GGML..."
    for i in $(ls "$1/$2"/ggml-model-f16.bin*); do
        if [ -f "${i/f16/q4_0}" ]; then
            echo "Skip model quantization, it already exists: ${i/f16/q4_0}"
        else
            echo "Converting PTH to GGML: $i into ${i/f16/q4_0}..."
            exec ./llama-quantize "$i" "${i/f16/q4_0}" q4_0
        fi
    done

elif [[ "$arg1" == '--server' || "$arg1" == '-s' ]]; then
    exec ./llama-server "$@"

else
    echo "Unknown command: $arg1"
    echo "Available commands:"
    echo "  --device (-d): Set ONEAPI_DEVICE_SELECTOR"
    echo "              ex: --device level_zero:0"
    echo "  --run (-r): Run a model (chat) previously converted into ggml"
    echo "              ex: -m /models/7B/ggml-model-q4_0.bin"
    echo "  --bench (-b): Benchmark the performance of the inference for various parameters."
    echo "              ex: -m model.gguf"
    echo "  --perplexity (-p): Measure the perplexity of a model over a given text."
    echo "              ex: -m model.gguf -f file.txt"
    echo "  --convert (-c): Convert a llama model into ggml"
    echo "              ex: --outtype f16 /models/7B/"
    echo "  --quantize (-q): Optimize with quantization process ggml"
    echo "              ex: /models/7B/ggml-model-f16.bin /models/7B/ggml-model-q4_0.bin 2"
    echo "  --all-in-one (-a): Execute --convert & --quantize"
    echo "              ex: /models/ 7B"
    echo "  --server (-s): Run a model on the server"
    echo "              ex: -m /models/7B/ggml-model-q4_0.bin -c 2048 -ngl 43 -mg 1 --port 8080"
fi

