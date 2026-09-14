# ORB Municipal Operator APK

Separate Flutter application for municipal Agent / Operator use.

## Frozen operator navigation

1. **Login** — Agent / Operator authentication
2. **Home (Page 1)** — Zone No + Ward No, then GSM/LTE, LoRa and MAP views
3. **GSM Valve Control (Page 2)** — operator valve control; no scheduling controls and no editable voltage-threshold controls
4. **LoRa Valve Control (Page 3)** — operator valve control; no scheduling controls and no editable voltage-threshold controls
5. **MAP (Page 4)** — valve map, add/remove/rebind workflow and scrollable valve list

## Explicitly removed from operator app

- RS485 / MODBUS Page 5
- Administrative sensor management
- Administrative device-driver management
- Scheduling configuration
- Editable voltage-threshold configuration

## Separation rule

This repository is intentionally separate from `muncipal-apk` (Admin). No Admin code is modified by this project. The operator application is wired independently against the frozen operator navigation and permissions.

## Build rule

Functional wiring is completed before visual polishing. Final visual adjustments can be made in Android Studio after all frozen views and navigation are verified.
