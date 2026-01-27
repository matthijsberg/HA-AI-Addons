FROM python:3.11-slim

ENV LANG C.UTF-8

# Install build dependencies if necessary
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
# We list them here for simplicity, but a requirements.txt is also fine.
# Added pydantic, aiohttp, websockets, google-auth, twilio
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
