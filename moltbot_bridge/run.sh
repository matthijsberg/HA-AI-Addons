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
    # Force internal WebSocket URL when using Supervisor Token
    export HA_URL="ws://supervisor/core/websocket"
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

# --- Moltbot Setup ---

echo "Setting up Moltbot..."

# 1. Get Config
GEMINI_KEY=$(jq -r '.gemini_api_key // empty' $CONFIG_PATH)
MODEL_NAME=$(jq -r '.model_name // "gemini-3.0-flash"' $CONFIG_PATH)

# 2. Install Moltbot (global)
echo "Installing/Updating Moltbot..."
npm install -g clawdbot@latest

# 3. Configure Moltbot
MOLTBOT_DIR="/root/.clawdbot"
mkdir -p "$MOLTBOT_DIR"
CONFIG_FILE="$MOLTBOT_DIR/clawdbot.json"

# Always create or update the config file to prevent "Missing config" error
echo "Updating Moltbot configuration..."
cat > "$CONFIG_FILE" <<EOF
{
  "gateway": {
    "mode": "local",
    "port": 18789
  },
  "llm": {
    "provider": "google-genai",
    "model": "$MODEL_NAME"
  },
  "logging": {
    "level": "info"
  }
}
EOF

if [ -n "$GEMINI_KEY" ] && [ "$GEMINI_KEY" != "null" ]; then
    echo "Gemini API Key detected. Setting environment variable."
    export GOOGLE_API_KEY="$GEMINI_KEY"
else
    echo "WARNING: No Gemini API Key provided. Use the add-on Configuration tab to add it."
fi

# 4. Start Moltbot in background
echo "Starting Moltbot Gateway..."
# Use --allow-unconfigured to ensure it starts even if some keys are missing initially
clawdbot gateway --port 18789 --allow-unconfigured &
MOLTBOT_PID=$!

# Wait for Moltbot to initialize
sleep 5

# --- Python Bridge Setup ---

echo "Starting Moltbot-HA Bridge Add-on with Log Level: $LOG_LEVEL"
python3 -u /app/bridge.py &
BRIDGE_PID=$!

# Wait for both
wait $MOLTBOT_PID $BRIDGE_PID
