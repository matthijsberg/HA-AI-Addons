ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gpg \
    wget \
    python3 \
    python3-pip \
    python3-psutil \
    clinfo \
    intel-opencl-icd \
    intel-level-zero-gpu \
    level-zero \
    intel-media-va-driver-non-free \
    libmfx1 \
    libvpl2 \
    && rm -rf /var/lib/apt/lists/*

# Add Intel oneAPI repository for SYCL/Level Zero runtimes
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    intel-oneapi-runtime-mkl \
    intel-oneapi-runtime-libs \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for hardware acceleration
ENV OLLAMA_INTEL_GPU=1
ENV ZES_ENABLE_SYSMAN=1
ENV DEVICE=NPU
ENV OLLAMA_NUM_GPU=999
ENV ONEAPI_DEVICE_SELECTOR=level_zero:0
ENV OLLAMA_HOST="0.0.0.0"
ENV OLLAMA_MODELS="/share/ollama/models"

# Install Ollama (force update to latest)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy files
COPY run.sh /
COPY check_hardware.py /
COPY fetch_models.py /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
