#!/usr/bin/with-contenv bashio

# Enable strict mode
set -e

echo "===================================================="
echo "          Starting HA AI Addons: Ollama             "
echo "===================================================="

# Check Hardware and give recommendations
echo "Analyzing system resources..."
python3 /check_hardware.py

# Retrieve configuration
MODEL=$(bashio::config 'model')
CUSTOM_MODEL=$(bashio::config 'custom_model')

if [ ! -z "$CUSTOM_MODEL" ]; then
    echo "Using Custom Model: $CUSTOM_MODEL"
    MODEL=$CUSTOM_MODEL
else
    echo "Using Selected Model: $MODEL"
fi

# Hardware Diagnostics
echo "--- Hardware Diagnostics ---"
echo "Checking /dev/dri:"
ls -l /dev/dri 2>/dev/null || echo "No /dev/dri found"
echo "Checking /dev/accel:"
ls -l /dev/accel 2>/dev/null || echo "No /dev/accel found"
echo "OpenCL Info (clinfo):"
clinfo -l 2>/dev/null || echo "clinfo failed"
echo "Environment for Ollama:"
env | grep OLLAMA || true
echo "---------------------------"

# Configure Ollama environment (redundant with ENV but kept for safety)
export OLLAMA_HOST="0.0.0.0"
export OLLAMA_MODELS="/share/ollama/models"
export OLLAMA_INTEL_GPU="1"
export ZES_ENABLE_SYSMAN=1

mkdir -p "$OLLAMA_MODELS"

# Start Ollama in background
echo "Starting Ollama Server..."
ollama serve &
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
if ollama list | grep -q "$MODEL"; then
    echo "Model '$MODEL' is cached and ready."
else
    echo "Model '$MODEL' not found. Downloading (this may take several minutes)..."
    ollama pull "$MODEL"
fi

echo "----------------------------------------------------"
echo " Ollama is running and model '$MODEL' is loaded.    "
echo " Internal URL: http://ollama:11434                  "
echo "----------------------------------------------------"

# Wait for process
wait $PID
