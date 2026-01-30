#!/usr/bin/env bashio

bashio::log.info "Starting Intel Arrow Lake Ollama Add-on..."

# --- 0. Environment Setup ---
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:${LD_LIBRARY_PATH:-}"
export OLLAMA_HOST="0.0.0.0:11434"
export OLLAMA_MODELS="/share/ollama_models"

# Load Config
KEEP_ALIVE=$(bashio::config 'keep_alive')
export OLLAMA_KEEP_ALIVE="$KEEP_ALIVE"

# --- 1. Hardware Check ---
if [ -d "/dev/dri" ]; then
    bashio::log.info "Intel GPU device files detected."
    
    # Force driver visibility
    export ZES_ENABLE_SYSMAN=1
    export OLLAMA_INTEL_GPU=1
    export SYCL_CACHE_PERSISTENT=1

    if clinfo -l | grep -i "Intel" | grep -q "GPU"; then
        GPU_NAME=$(clinfo | grep "Device Name" | head -n 1 | awk -F: '{print $2}' | xargs)
        bashio::log.info "OpenCL detected Intel GPU: $GPU_NAME"
    else
        bashio::log.warning "OpenCL did not detect Intel GPU, but /dev/dri exists. Proceeding with Level Zero."
    fi
else
    bashio::log.warning "ATTENTION: No Intel GPU detected (/dev/dri missing). Falling back to CPU (slow)."
fi

# --- 2. Start Ollama (Background) ---
bashio::log.info "Starting Ollama server..."
ollama serve &
PID=$!

# Wait for API to be ready
bashio::log.info "Waiting for Ollama API..."
until curl -s -f "http://localhost:11434/" > /dev/null; do
    sleep 1
done
bashio::log.info "Ollama is online!"

# --- 3. Model Management ---
MODEL=$(bashio::config 'model')
bashio::log.info "Checking model: $MODEL"

if ollama list | grep -q "$MODEL"; then
    bashio::log.info "Model '$MODEL' already present."
else
    bashio::log.info "Downloading '$MODEL'. This may take a while..."
    ollama pull "$MODEL"
    bashio::log.info "Download of '$MODEL' complete."
fi

# --- 4. Keep Running ---
bashio::log.info "Ready to serve. Keep-alive set to: $KEEP_ALIVE"
wait "$PID"