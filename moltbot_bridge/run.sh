#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Extract config values using jq
export LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)
# Use internal WebSocket URL by default
export HA_URL=$(jq --raw-output '.ha_url // "ws://supervisor/core/websocket"' $CONFIG_PATH)
export HA_TOKEN=$(jq --raw-output '.ha_token // empty' $CONFIG_PATH)

# If HA_TOKEN is not provided in config, try to use the supervisor token
if [ -z "$HA_TOKEN" ]; then
    echo "Using Supervisor Token"
    export HA_TOKEN=$SUPERVISOR_TOKEN
fi

export BLUEBUBBLES_URL=$(jq --raw-output '.bluebubbles_url // empty' $CONFIG_PATH)
export BLUEBUBBLES_TOKEN=$(jq --raw-output '.bluebubbles_token // empty' $CONFIG_PATH)

export WHATSAPP_PROVIDER=$(jq --raw-output '.whatsapp_provider // "twilio"' $CONFIG_PATH)
export WHATSAPP_SID=$(jq --raw-output '.whatsapp_sid // empty' $CONFIG_PATH)
export WHATSAPP_TOKEN=$(jq --raw-output '.whatsapp_token // empty' $CONFIG_PATH)
export WHATSAPP_FROM=$(jq --raw-output '.whatsapp_from // empty' $CONFIG_PATH)

echo "Starting Moltbot-HA Bridge Add-on with Log Level: $LOG_LEVEL"

exec python3 bridge.py
