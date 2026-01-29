#!/usr/bin/with-contenv bashio
bashio::log.info "--- OLLAMA UNIVERSAL ACCELERATION STARTUP ---"

# 1. Hardware Enumeration & Requirement Check
UBUNTU_VER=$(grep "VERSION_ID" /etc/os-release | cut -d= -f2 | xargs)
KERNEL_VER=$(uname -r)
bashio::log.info "Host Environment -> OS: Ubuntu ${UBUNTU_VER}, Kernel: ${KERNEL_VER}"

# 2. Dynamic Backend Configuration
ACCEL_CHOICE=$(bashio::config 'accelerator')
GPU_IDX=$(bashio::config 'gpu_index')
bashio::log.info "Configuring for ${ACCEL_CHOICE} (Index: ${GPU_IDX})..."

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
        bashio::log.err "❌ NPU device node missing. Check HAOS kernel version (needs 6.12+)."
    fi
    ;;
  "vulkan")
    # Generic Cross-Vendor Path (NVIDIA/AMD/Legacy Intel)
    export OLLAMA_VULKAN=1
    export GGML_VK_VISIBLE_DEVICES="${GPU_IDX}"
    export OLLAMA_NUM_GPU=999
    bashio::log.info "Using experimental Vulkan backend for generic GPU support."
    ;;
  "cpu")
    export OLLAMA_NUM_GPU=0
    ;;
esac

# 3. Global Runtime Tuning
export ZES_ENABLE_SYSMAN=1
export SYCL_CACHE_PERSISTENT=1
export OLLAMA_KEEP_ALIVE=$(bashio::config 'keep_alive')

bashio::log.info "Launching Ollama Server..."
exec /usr/bin/ollama serve
