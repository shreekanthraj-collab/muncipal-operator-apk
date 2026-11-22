# ORB Municipal Operator APK

Separate Flutter application for municipal Agent / Operator use.

## Frozen operator navigation

1. **Login** — Agent / Operator authentication
2. **Home (Page 1)** — Zone No + Ward No, then GSM/LTE, LoRa, MAP and RS485 views
3. **GSM Valve Control (Page 2)** — operator valve control; existing frozen controls retained
4. **LoRa Valve Control (Page 3)** — operator valve control; existing frozen controls retained
5. **MAP (Page 4)** — valve map and scrollable valve list
6. **RS485 / MODBUS (Page 5)** — eight fixed device slots, device status cards, manual configuration, scan entry point, driver search and candidate-driver entry points

## RS485 page freeze baseline

- Preserve the supplied RS485 / MODBUS card layout: numbered slots, model/slave identity, status, measurement value and CONFIG action.
- Support different manufacturers through a verified Modbus driver profile; do not hard-code one manufacturer.
- A sealed device is configured from its external nameplate and manufacturer communication/register manual. No physical opening is required.
- Configuration fields include manufacturer, model, slave ID, baud rate, parity, start register, register count, measurement and unit.
- A slave-address scan cannot identify the make/model or infer the register map.
- Do not invent register addresses, scaling, data types or units.
- RS485 device commissioning is separate from actuator EOL. No RS485 sensor/device EOL test is included.
- The current page saves configuration only in the running UI session. Gateway/server persistence, live discovery, driver catalogue search and live measurement telemetry are not connected in this branch and must not be represented as operational until integrated and tested.

## Separation rule

This repository is intentionally separate from `muncipal-apk` (Admin). No Admin code is modified by this project. Existing GSM and LoRa valve-control screens are retained.

## Build rule

Functional wiring is completed before visual polishing. The restored Page 5 is a UI/configuration baseline; complete gateway/server integration and Flutter build validation before production release.
