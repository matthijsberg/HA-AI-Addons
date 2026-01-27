#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Extract config values using jq
export LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)
# Use internal WebSocket URL by default
# If HA_TOKEN is not provided in config, use Supervisor Token and INTERNAL URL
if [ -z "$HA_TOKEN" ]; then
    echo "Auto-configuring Home Assistant Connection..."
    export HA_TOKEN=$SUPERVISOR_TOKEN
    # Force direct connection to HA Core container (bypassing supervisor proxy)
    export HA_URL="ws://homeassistant:8123/api/websocket"
else
    # Manual mode: Use configured URL (or default if null)
    export HA_URL=$(jq --raw-output '.ha_url // "ws://supervisor/core/websocket"' $CONFIG_PATH)
fi

export BLUEBUBBLES_URL=$(jq --raw-output '.bluebubbles_url // empty' $CONFIG_PATH)
export BLUEBUBBLES_TOKEN=$(jq --raw-output '.bluebubbles_token // empty' $CONFIG_PATH)

export WHATSAPP_PROVIDER=$(jq --raw-output '.whatsapp_provider // "twilio"' $CONFIG_PATH)
export WHATSAPP_SID=$(jq --raw-output '.whatsapp_sid // empty' $CONFIG_PATH)
export WHATSAPP_TOKEN=$(jq --raw-output '.whatsapp_token // empty' $CONFIG_PATH)
export WHATSAPP_FROM=$(jq --raw-output '.whatsapp_from // empty' $CONFIG_PATH)

echo "Starting Moltbot-HA Bridge Add-on with Log Level: $LOG_LEVEL"

exec python3 bridge.py
