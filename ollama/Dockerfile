ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    python3 \
    python3-pip \
    python3-psutil \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
# We use the install script which detects arch
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy files
COPY run.sh /
COPY check_hardware.py /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
