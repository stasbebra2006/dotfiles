#!/bin/bash
# Script to fix KDE Wayland dimming / Powerdevil hangs
set -euo pipefail

echo "=========================================="
echo "      KDE Wayland Brightness Repair       "
echo "=========================================="

# 1. Restart Powerdevil service
echo "[*] Restarting plasma-powerdevil service..."
systemctl --user restart plasma-powerdevil.service || echo "[!] Failed to restart plasma-powerdevil service, continuing..."
sleep 2

# 2. Toggle Night Color to force compositor refresh and suspend Night Light
echo "[*] Triggering temporary Night Color preview to refresh compositor gamma/color layers..."
if busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight preview u 5000 >/dev/null 2>&1; then
    sleep 1
    busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight stopPreview >/dev/null 2>&1 || true
    echo "[+] Compositor color layers refreshed."
else
    echo "[!] Night Color preview failed to trigger, continuing..."
fi

echo "[*] Suspending Night Light (Night Shift)..."
busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight inhibit >/dev/null 2>&1 || true
# Verify Night Light inhibition status
inhibited_status=$(busctl --user get-property org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight inhibited 2>/dev/null | awk '{print $2}' || echo "false")
if [ "$inhibited_status" = "true" ]; then
    echo "[+] Night Light (Night Shift) is left suspended."
else
    echo "[!] Warning: Could not verify Night Light (Night Shift) suspension state."
fi

# 3. Retrieve display DBus paths under org.kde.ScreenBrightness
echo "[*] Enumerating displays on org.kde.ScreenBrightness DBus interface..."
displays=$(busctl --user tree org.kde.ScreenBrightness 2>/dev/null | grep -o '/org/kde/ScreenBrightness/display[0-9]*' || true)

if [ -z "$displays" ]; then
    echo "[!] No DBus display nodes found under /org/kde/ScreenBrightness."
    echo "[*] Falling back to kscreen-doctor to restore brightness to 100%..."
    # Find all outputs from kscreen-doctor -o
    outputs=$(kscreen-doctor -o 2>/dev/null | grep -oE "Output: [0-9]+ [A-Za-z0-9-]+" | awk '{print $3}' || true)
    if [ -z "$outputs" ]; then
        echo "[!] Fallback failed: kscreen-doctor could not list any outputs."
    else
        for out in $outputs; do
            echo "[*] Setting output '$out' to 100% brightness..."
            kscreen-doctor output."$out".brightness.100 || true
        done
    fi
else
    for disp in $displays; do
        # Get label if possible
        label=$(busctl --user get-property org.kde.ScreenBrightness "$disp" org.kde.ScreenBrightness.Display Label 2>/dev/null | cut -d'"' -f2 || echo "Unknown Display")
        echo "[+] Found display: $label ($disp)"
        echo "[*] Setting software brightness/dimming for '$label' to 100% (10000)..."
        busctl --user call org.kde.ScreenBrightness "$disp" org.kde.ScreenBrightness.Display SetBrightness iu 10000 0 || true
    done
fi

echo "=========================================="
echo "Brightness restoration completed successfully!"
echo "=========================================="
