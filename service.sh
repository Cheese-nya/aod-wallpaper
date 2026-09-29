#!/system/bin/sh
# ==============================================================================
# AOD Wallpaper & Xiaomi 15 1Hz LTPO Hardware Service (v1.0)
# Author: Cheese | GitHub: Cheese-nya
# ==============================================================================

MODDIR="/data/adb/modules/aod_wallpaper"
CONFIG_FILE="$MODDIR/config.prop"
SHORTCUT_CONFIG="/data/adb/aod_config.prop"
LOG_FILE="$MODDIR/aod_service.log"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE" 2>/dev/null
}

# 等待系统开机完成
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# 等待核心服务就绪
sleep 3

log_msg "AOD v1.0 (Xiaomi 15 1Hz LTPO & Apple-Style) service started"

# 创建快捷方式
rm -f "$SHORTCUT_CONFIG" 2>/dev/null
if [ -f "$CONFIG_FILE" ]; then
    ln -sf "$CONFIG_FILE" "$SHORTCUT_CONFIG" 2>/dev/null
    log_msg "Created symlink: $SHORTCUT_CONFIG -> $CONFIG_FILE"
fi

# ========================================================
# 应用配置参数函数 (支持热重载)
# ========================================================
apply_config() {
    # 读取配置文件
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE" 2>/dev/null
    fi

    # 1. 壁纸开关
    if [ "$AOD_WALLPAPER_ENABLE" = "0" ]; then
        settings put secure doze_always_on_wallpaper_enabled 0
        log_msg "Applied: wallpaper disabled (black AOD)"
    else
        settings put secure doze_always_on_wallpaper_enabled 1
        settings put secure doze_always_on 1
        log_msg "Applied: wallpaper enabled"
    fi

    # 2. 模糊滤镜控制 (0: 默认灰色滤镜/关闭模糊, 1: 启用模糊)
    if [ "$AOD_BLUR_FILTER" = "1" ]; then
        settings put global disable_window_blurs 0
        log_msg "Applied: blur filter enabled (disable_window_blurs=0)"
    else
        # 默认：灰色滤镜 (无模糊，壁纸清晰透亮)
        settings put global disable_window_blurs 1
        log_msg "Applied: default grey filter (disable_window_blurs=1, no blur)"
    fi

    # 3. 解除系统全局最小刷新率锁死
    if [ "$AOD_UNLOCK_MIN_FPS" != "0" ]; then
        settings put system min_refresh_rate 0.0 2>/dev/null
        log_msg "Applied: set min_refresh_rate=0.0"
    fi

    # 4. 刷新率与硬件驱动节点
    TARGET_FPS="${AOD_REFRESH_RATE:-1}"
    if [ -f "/sys/class/mi_display/disp-DSI-0/wp_aod" ]; then
        if [ "$TARGET_FPS" = "1" ]; then
            echo 1 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
            echo 2 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
        else
            echo 0 > /sys/class/mi_display/disp-DSI-0/wp_aod 2>/dev/null
        fi
    fi

    for node in /sys/class/drm/*/idle_time; do
        [ -f "$node" ] && echo 50 > "$node" 2>/dev/null
    done

    for node in /sys/class/drm/*/idle_fps; do
        [ -f "$node" ] && echo "$TARGET_FPS" > "$node" 2>/dev/null
    done

    for node in /sys/devices/platform/soc/*qcom,dsi-display*/dynamic_fps; do
        [ -f "$node" ] && echo 1 > "$node" 2>/dev/null
    done

    for node in /sys/class/drm/sde-crtc-*/idle_time; do
        [ -f "$node" ] && echo 50 > "$node" 2>/dev/null
    done

    log_msg "Applied hardware nodes for target fps: $TARGET_FPS"
}

# 开机初次应用
apply_config

# 后台守护进程：基于 MD5 哈希的可靠热重载监听
(
    LAST_HASH=""
    while true; do
        sleep 4
        
        if [ -f "$CONFIG_FILE" ]; then
            CUR_HASH=$(md5sum "$CONFIG_FILE" 2>/dev/null | awk '{print $1}')
            if [ -n "$CUR_HASH" ] && [ "$CUR_HASH" != "$LAST_HASH" ]; then
                if [ -n "$LAST_HASH" ]; then
                    log_msg "Detected config.prop change (MD5 changed), hot-reloading immediately..."
                    apply_config
                fi
                LAST_HASH="$CUR_HASH"
            fi
        fi
        
        # 定期维持硬件节点
        for node in /sys/class/drm/*/idle_fps; do
            [ -f "$node" ] && echo "${AOD_REFRESH_RATE:-1}" > "$node" 2>/dev/null
        done
    done
) &

log_msg "AOD v1.0 daemon active (MD5 hot-reload & Apple-Style anti-burn-in)"
