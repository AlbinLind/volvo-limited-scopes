# Volvo (Limited Scopes) for Home Assistant

A custom version of the [Home Assistant Volvo integration](https://www.home-assistant.io/integrations/volvo/) that excludes sensitive command scopes.

## Why?

The official Volvo integration requests **all available scopes** during OAuth authorization, including:
- 🔓 **Lock/Unlock** your car
- 🚗 **Start/Stop engine**
- 📢 **Honk & Flash**

If you create a restricted app in the [Volvo Developer Portal](https://developer.volvocars.com/) without these permissions, the integration refuses to connect.

This custom component solves that by only requesting **read-only scopes**, allowing you to:
- ✅ View all vehicle data (battery, fuel, odometer, etc.)
- ✅ Track your car's location
- ✅ See door/window/warning statuses
- ❌ ~~Lock/Unlock the car~~ (excluded)
- ❌ ~~Start/Stop engine~~ (excluded)
- ❌ ~~Honk & Flash~~ (excluded)

## Installation

### Manual Installation

1. Download the latest release from [Releases](../../releases)
2. Extract `volvo-limited-scopes.zip`
3. Copy the `volvo` folder to `<config>/custom_components/`
4. Restart Home Assistant

### HACS (Manual)

1. Add this repository as a custom repository in HACS
2. Search for "Volvo (Limited Scopes)"
3. Install and restart Home Assistant

## Volvo Developer Portal Setup

1. Go to [Volvo Developer Portal](https://developer.volvocars.com/account/#your-api-applications)
2. Create a new application
3. Enable **only** the read permissions you need:
   - Battery & charge
   - Diagnostics
   - Fuel status
   - Location
   - Odometer
   - Trip statistics
   - Vehicle relation
4. **Do NOT enable** lock, unlock, engine start/stop, or honk/flash
5. Use the API key from this app in Home Assistant

## Updating

This integration is automatically synced with the upstream [Home Assistant Volvo integration](https://github.com/home-assistant/core/tree/dev/homeassistant/components/volvo).

Check the [Releases](../../releases) page for updates. RC (Release Candidate) versions are published weekly when upstream changes are detected.

## Configuration

The integration works exactly like the official one. See the [official documentation](https://www.home-assistant.io/integrations/volvo/) for setup instructions.

## Limitations

- Command buttons that require excluded scopes will not be created
- If you need climatization control, you may need to modify the `LIMITED_SCOPES` list in `const.py`

## Credits

- Original integration by [@thomasddn](https://github.com/thomasddn)
- Part of [Home Assistant Core](https://github.com/home-assistant/core)

## License

Apache License 2.0 (same as Home Assistant)
