#!/bin/bash

# Helper function for logging
log_info() {
    echo "[INFO] $1"
}

log_err() {
    echo "[ERROR] $1" >&2
}

log_info "--- OLLAMA UNIVERSAL ACCELERATION STARTUP ---"

# 1. Hardware Enumeration & Requirement Check
if [ -f /etc/os-release ]; then
    UBUNTU_VER=$(grep "VERSION_ID" /etc/os-release | cut -d= -f2 | xargs)
else
    UBUNTU_VER="Unknown"
fi
KERNEL_VER=$(uname -r)
log_info "Host Environment -> OS: Ubuntu ${UBUNTU_VER}, Kernel: ${KERNEL_VER}"

# Debug: Hardware Diagnostics
log_info "--- Debug: /dev/dri Listing ---"
ls -l /dev/dri 2>/dev/null || log_err "No /dev/dri found"

log_info "--- Debug: clinfo Output ---"
if command -v clinfo &> /dev/null; then
    clinfo
else
    log_err "clinfo command not found"
fi
log_info "--- End Debug ---"

# 2. Dynamic Backend Configuration
CONFIG_PATH="/data/options.json"

if [ -f "$CONFIG_PATH" ]; then
    ACCEL_CHOICE=$(jq -r '.accelerator // "cpu"' "$CONFIG_PATH")
    GPU_IDX=$(jq -r '.gpu_index // 0' "$CONFIG_PATH")
    KEEP_ALIVE=$(jq -r '.keep_alive // "5m"' "$CONFIG_PATH")
else
    log_info "Config file not found at $CONFIG_PATH, using defaults."
    ACCEL_CHOICE="cpu"
    GPU_IDX=0
    KEEP_ALIVE="5m"
fi

log_info "Configuring for ${ACCEL_CHOICE} (Index: ${GPU_IDX})..."

case $ACCEL_CHOICE in
  "gpu")
    # Intel-specific SYCL/oneAPI Path
    export ONEAPI_DEVICE_SELECTOR="level_zero:${GPU_IDX}"
    export OLLAMA_NUM_GPU=999
    ;;
  "npu")
    # Intel-specific NPU Path
    export ONEAPI_DEVICE_SELECTOR="level_zero:npu"
    export OLLAMA_NUM_GPU=999
    if [ ! -e "/dev/accel/accel0" ]; then
        log_err "❌ NPU device node missing. Check HAOS kernel version (needs 6.12+)."
    fi
    ;;
  "vulkan")
    # Generic Cross-Vendor Path (NVIDIA/AMD/Legacy Intel)
    export OLLAMA_VULKAN=1
    export GGML_VK_VISIBLE_DEVICES="${GPU_IDX}"
    export OLLAMA_NUM_GPU=999
    log_info "Using experimental Vulkan backend for generic GPU support."
    ;;
  "cpu")
    export OLLAMA_NUM_GPU=0
    ;;
esac

# 3. Global Runtime Tuning
export ZES_ENABLE_SYSMAN=1
export SYCL_CACHE_PERSISTENT=1
export OLLAMA_KEEP_ALIVE="$KEEP_ALIVE"

log_info "Launching Ollama Server..."
exec /usr/bin/ollama serve
