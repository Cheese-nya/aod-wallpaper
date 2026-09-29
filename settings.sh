#!/system/bin/sh

MODDIR="/data/adb/modules/aod_wallpaper"
CONFIG_FILE="$MODDIR/config.prop"

echo "==================================="
echo "  AOD Wallpaper Settings (Magisk) "
echo "==================================="
echo ""
echo "1) Enable AOD Wallpaper"
echo "2) Disable AOD Wallpaper (Black Screen)"
echo "3) Enable Blur Filter"
echo "4) Disable Blur Filter (Grey Filter - Default)"
echo "5) Set Refresh Rate to 1Hz (Extreme battery saving)"
echo "6) Set Refresh Rate to 30Hz"
echo "7) Set Refresh Rate to 60Hz"
echo "0) Exit"
echo ""
printf "Enter your choice: "
read choice

case "$choice" in
    1)
        sed -i 's/AOD_WALLPAPER_ENABLE=.*/AOD_WALLPAPER_ENABLE=1/' "$CONFIG_FILE"
        settings put secure doze_always_on_wallpaper_enabled 1
        settings put secure doze_always_on 1
        echo "Enabled AOD Wallpaper."
        ;;
    2)
        sed -i 's/AOD_WALLPAPER_ENABLE=.*/AOD_WALLPAPER_ENABLE=0/' "$CONFIG_FILE"
        settings put secure doze_always_on_wallpaper_enabled 0
        echo "Disabled AOD Wallpaper."
        ;;
    3)
        sed -i 's/AOD_BLUR_FILTER=.*/AOD_BLUR_FILTER=1/' "$CONFIG_FILE"
        settings put global disable_window_blurs 0
        echo "Enabled Blur Filter."
        ;;
    4)
        sed -i 's/AOD_BLUR_FILTER=.*/AOD_BLUR_FILTER=0/' "$CONFIG_FILE"
        settings put global disable_window_blurs 1
        echo "Disabled Blur Filter (Using Grey Filter)."
        ;;
    5)
        sed -i 's/AOD_REFRESH_RATE=.*/AOD_REFRESH_RATE=1/' "$CONFIG_FILE"
        echo 1 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
        echo 2 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
        for node in /sys/class/drm/*/idle_fps; do [ -f "$node" ] && echo 1 > "$node"; done
        echo "Set Refresh Rate to 1Hz."
        ;;
    6)
        sed -i 's/AOD_REFRESH_RATE=.*/AOD_REFRESH_RATE=30/' "$CONFIG_FILE"
        echo 0 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
        for node in /sys/class/drm/*/idle_fps; do [ -f "$node" ] && echo 30 > "$node"; done
        echo "Set Refresh Rate to 30Hz."
        ;;
    7)
        sed -i 's/AOD_REFRESH_RATE=.*/AOD_REFRESH_RATE=60/' "$CONFIG_FILE"
        echo 0 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
        for node in /sys/class/drm/*/idle_fps; do [ -f "$node" ] && echo 60 > "$node"; done
        echo "Set Refresh Rate to 60Hz."
        ;;
    0)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        ;;
esac

echo "Settings saved and applied!"
