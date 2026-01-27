FROM python:3.11-bookworm

ENV LANG C.UTF-8

# Install build dependencies and Node.js
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    curl \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir \
    aiohttp \
    websockets \
    pydantic \
    google-auth \
    google-auth-oauthlib \
    google-auth-httplib2 \
    twilio \
    matrix-nio

# Copy application files
COPY . .

# Make run script executable
RUN chmod +x run.sh

CMD [ "./run.sh" ]
