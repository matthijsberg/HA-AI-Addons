# Moltbot-HA Bridge Add-on

A Home Assistant Add-on that serves as a central intelligence bridge, inspired by the Moltbot framework. It connects Home Assistant, Google Ecosystems, and Messaging platforms (BlueBubbles for iMessage, WhatsApp) into a unified control agent.

## Features

- **Home Assistant Integration**: Full read/write access via WebSocket API.
- **Messaging Bridge**:
    - **iMessage**: via BlueBubbles Server.
    - **WhatsApp**: via Twilio or Matrix Bridge.
- **Google Integration**: OAuth2 connection for syncing device states.
- **Secure**: Uses Home Assistant's internal secret management and strict config validation.

## Installation

1.  Copy the `moltbot_bridge` folder to your Home Assistant `addons/` directory (local add-on).
2.  Refresh the Add-on Store in Home Assistant.
3.  Install "Moltbot-HA Bridge Add-on".

## Configuration

Configure the add-on via the "Configuration" tab in Home Assistant.

```yaml
log_level: info
ha_url: http://supervisor/core/api  # Default
ha_token: "YOUR_LONG_LIVED_ACCESS_TOKEN" # Optional if using Supervisor API
bluebubbles_url: "http://your-bluebubbles-server:1234"
bluebubbles_token: "YOUR_BB_PASSWORD"
whatsapp_provider: "twilio"
whatsapp_sid: "AC..."
whatsapp_token: "..."
whatsapp_from: "+1234567890"
```

## OAuth Setup (Google)

To enable Google integration:
1.  Go to Google Cloud Console.
2.  Create a project and enable relevant APIs (HomeGraph, etc.).
3.  Create OAuth 2.0 Credentials.
4.  Download the JSON file and place it in `/config/moltbot/google_creds.json` (inside HA).
    *Note: Future versions will support pasting the JSON directly into the config.*

## Development

Built with Python 3.11 using `aiohttp` and `websockets`.

### Structure

- `bridge.py`: Main entry point and orchestration logic.
- `config.yaml`: Add-on metadata and configuration schema.
- `Dockerfile`: Build instructions.
