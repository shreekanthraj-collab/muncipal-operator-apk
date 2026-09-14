# Municipal Operator APK

Separate Flutter application for municipal Agent / Operator use.

## Frozen navigation

1. Login — Agent / Operator authentication
2. Home — Zone No + Ward No, then GSM/LTE, LoRa, MAP and RS485 views
3. GSM Valve Control — assigned GSM/LTE valves and operator valve controls
4. LoRa Valve Control — assigned LoRa valves and operator valve controls
5. MAP — valve map and scrollable valve list
6. RS485 / MODBUS — operator device/status view

## Separation rule

This repository is intentionally separate from `muncipal-apk` (Admin). No Admin code is modified by this project. Admin-only sensor management, device-driver management, and other administrative functions are not exposed in the operator flow.

Visual polishing can be done in Android Studio after functional wiring is verified.
