#!/bin/bash

# Enable strict mode
set -e

echo "===================================================="
echo "          Starting HA AI Addons: Ollama             "
echo "===================================================="

# Check Hardware and give recommendations
echo "Analyzing system resources..."
python3 /check_hardware.py

# Retrieve configuration
if [ -f /data/options.json ]; then
    MODEL=$(python3 -c "import sys, json; print(json.load(open('/data/options.json')).get('model', '') or '')")
    CUSTOM_MODEL=$(python3 -c "import sys, json; print(json.load(open('/data/options.json')).get('custom_model', '') or '')")
    DEVICE_TYPE=$(python3 -c "import sys, json; print(json.load(open('/data/options.json')).get('device_type', 'NPU') or 'NPU')")
else
    MODEL=${MODEL:-"llama3:8b"}
    CUSTOM_MODEL=${CUSTOM_MODEL:-""}
    DEVICE_TYPE=${DEVICE_TYPE:-"NPU"}
fi

# Set DEVICE for IPEX init
DEVICE="$DEVICE_TYPE"
# Map generic GPU to iGPU for IPEX init if needed
if [ "$DEVICE" = "GPU" ]; then
    DEVICE="iGPU"
fi

if [ ! -z "$CUSTOM_MODEL" ]; then
    echo "Using Custom Model: $CUSTOM_MODEL"
    MODEL=$CUSTOM_MODEL
else
    echo "Using Selected Model: $MODEL"
fi

# IPEX and Ollama Initialization
echo "--- IPEX Initialization ---"
# Source the IPEX environment (this sets up SYCL and oneAPI paths)
# Note: we use . because source might not be available in some shells
. ipex-llm-init --gpu --device "$DEVICE" || echo "IPEX-LLM init failed, continuing anyway..."

echo "--- Ollama Initialization ---"
# The IPEX image expects ollama to be initialized in a specific way
mkdir -p /llm/ollama
cd /llm/ollama
if [ ! -f "./ollama" ]; then
    echo "Initializing Ollama binary..."
    init-ollama || echo "init-ollama failed"
fi

# Hardware Diagnostics
echo "--- Hardware Diagnostics ---"
echo "Checking /dev/dri:"
ls -l /dev/dri 2>/dev/null || echo "No /dev/dri found"
echo "Checking /dev/accel:"
ls -l /dev/accel 2>/dev/null || echo "No /dev/accel found"
echo "SYCL Devices (sycl-ls):"
sycl-ls 2>/dev/null || echo "sycl-ls not found or failed"
echo "Environment for Ollama:"
env | grep -E "OLLAMA|DEVICE|ZES|ONEAPI" || true
echo "---------------------------"

# Configure Ollama environment
export OLLAMA_HOST="0.0.0.0"
export OLLAMA_MODELS="/share/ollama/models"
export OLLAMA_ORIGINS="*"
export OLLAMA_INTEL_GPU="1"
export ZES_ENABLE_SYSMAN=1
export DEVICE="$DEVICE_TYPE"
export OLLAMA_NUM_GPU=999
export ONEAPI_DEVICE_SELECTOR="level_zero:0"

mkdir -p "$OLLAMA_MODELS"

# Start Ollama in background
echo "Starting Ollama Server..."
# Use the local ollama binary created by init-ollama
./ollama serve &
PID=$!

# Wait for Ollama to start
echo "Waiting for Ollama API to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0
until curl -s http://localhost:11434/api/tags > /dev/null || [ $RETRY_COUNT -eq $MAX_RETRIES ]; do
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Error: Ollama server failed to start within 60 seconds."
    exit 1
fi

echo "Ollama API is active!"

# Pull the requested model if not present
if ./ollama list | grep -q "$MODEL"; then
    echo "Model '$MODEL' is cached and ready."
else
    echo "Model '$MODEL' not found. Downloading (this may take several minutes)..."
    ./ollama pull "$MODEL"
fi

echo "----------------------------------------------------"
echo " Ollama is running and model '$MODEL' is loaded.    "
echo " Internal URL: http://ollama:11434                  "
echo "----------------------------------------------------"

# Start Web UI
echo "Starting Web UI..."
if ! python3 -c "import requests" 2>/dev/null; then
    echo "Warning: python3-requests not found. Attempting to install..."
    apt-get update && apt-get install -y python3-requests || echo "Failed to install requests"
fi

python3 -u /web_server.py 2>&1 &
WEB_PID=$!

# Wait for process
wait $PID $WEB_PID
