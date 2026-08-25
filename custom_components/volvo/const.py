"""Constants for the Volvo integration."""

from homeassistant.const import Platform

DOMAIN = "volvo"

# Limited scopes - excludes sensitive commands
LIMITED_SCOPES = [
    "openid",
    "conve:battery_charge_level",
    "conve:brake_status",
    "conve:climatization_start_stop",
    "conve:command_accessibility",
    "conve:commands",
    "conve:diagnostics_engine_status",
    "conve:diagnostics_workshop",
    "conve:doors_status",
    "conve:engine_status",
    "conve:fuel_status",
    "conve:lock_status",
    "conve:odometer_status",
    "conve:trip_statistics",
    "conve:tyre_status",
    "conve:vehicle_relation",
    "conve:warnings",
    "conve:windows_status",
    "energy:capability:read",
    "energy:state:read",
    "location:read",
]
# Excluded sensitive scopes:
# - conve:lock (lock car)
# - conve:unlock (unlock car)
# - conve:engine_start_stop (start/stop engine)
# - conve:honk_flash (honk and flash)

PLATFORMS: list[Platform] = [
    Platform.BINARY_SENSOR,
    Platform.BUTTON,
    Platform.DEVICE_TRACKER,
    Platform.LOCK,
    Platform.SENSOR,
]

API_NONE_VALUE = "UNSPECIFIED"
CONF_VIN = "vin"
DATA_BATTERY_CAPACITY = "battery_capacity_kwh"
MANUFACTURER = "Volvo"
