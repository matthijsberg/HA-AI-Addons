# Moltbot-HA Bridge Add-on Documentation

This bridge connects Home Assistant with various messaging platforms and ecosystem services.

## Home Assistant Setup

### Long-lived Access Token
1. Click on your profile name in the bottom left of the Home Assistant sidebar.
2. Scroll to the bottom and find **Long-lived Access Tokens**.
3. Create a new token and name it `Moltbot Bridge`.
4. Copy this token into the `ha_token` field in the add-on configuration.

### Discovery URL
If the add-on is running in the same instance, use:
`http://supervisor/core/api`

## Messaging Platforms

### Twilio (WhatsApp)
1. Go to the [Twilio Console](https://www.twilio.com/console).
2. Find your **Account SID** and **Auth Token** on the dashboard.
3. For the **From** field, use your WhatsApp enabled Twilio phone number (e.g., `whatsapp:+14155238886`).

### BlueBubbles (iMessage)
1. Ensure you have a BlueBubbles server running on a Mac.
2. Go to the BlueBubbles server settings to find your **Server URL** and **API Password**.

### Matrix
1. You will need a **Home Server URL** and an **Access Token** for a dedicated bridge user.
2. Consult your Matrix provider on how to generate a bot/access token.

## Google Home Integration
1. Place your `google_creds.json` file in the `/config/moltbot/` directory on your Home Assistant machine.
2. The bridge will automatically detect and use these credentials for HomeGraph synchronization.
