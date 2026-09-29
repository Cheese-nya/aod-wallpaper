ui_print "**********************************************"
ui_print "*   AOD Wallpaper · Xiaomi 15 · Apple-Style *"
ui_print "*   v1.0 by Cheese (GitHub: Cheese-nya)     *"
ui_print "**********************************************"

ui_print "- 正在检测系统 SystemUI 安装路径..."

TARGET_PATHS=""

for p in \
    /system_ext/priv-app/SystemUI/SystemUI.apk \
    /system/system_ext/priv-app/SystemUI/SystemUI.apk \
    /product/priv-app/SystemUI/SystemUI.apk \
    /system/product/priv-app/SystemUI/SystemUI.apk \
    /system/priv-app/SystemUI/SystemUI.apk
do
    if [ -f "$p" ]; then
        ui_print "  > 探测到系统文件: $p"
        case "$p" in
            /system_ext/*)
                TARGET_PATHS="$TARGET_PATHS system/system_ext/priv-app/SystemUI system_ext/priv-app/SystemUI"
                ;;
            /system/system_ext/*)
                TARGET_PATHS="$TARGET_PATHS system/system_ext/priv-app/SystemUI system_ext/priv-app/SystemUI"
                ;;
            /product/*)
                TARGET_PATHS="$TARGET_PATHS system/product/priv-app/SystemUI product/priv-app/SystemUI"
                ;;
            /system/product/*)
                TARGET_PATHS="$TARGET_PATHS system/product/priv-app/SystemUI product/priv-app/SystemUI"
                ;;
            /system/priv-app/*)
                TARGET_PATHS="$TARGET_PATHS system/priv-app/SystemUI"
                ;;
        esac
        break
    fi
done

if [ -z "$TARGET_PATHS" ]; then
    ui_print "  > 未直接探测到运行路径，按标准 system_ext/priv-app/SystemUI 部署"
    TARGET_PATHS="system/system_ext/priv-app/SystemUI system_ext/priv-app/SystemUI"
fi

if [ -f "$MODPATH/SystemUI.apk" ]; then
    for rel in $TARGET_PATHS; do
        mkdir -p "$MODPATH/$rel"
        cp -f "$MODPATH/SystemUI.apk" "$MODPATH/$rel/SystemUI.apk"
        ui_print "  + 已安装 SystemUI -> $rel/SystemUI.apk"
    done
    rm -f "$MODPATH/SystemUI.apk"
else
    ui_print "! 错误: 模块包中缺少 SystemUI.apk"
    abort
fi

# 配置文件管理
rm -f /data/adb/aod_config.prop 2>/dev/null

# 清理 Dalvik 缓存与编译产物，确保 ART 重新编译并加载新补丁
ui_print "- 正在清理 services.jar 与 SystemUI 的 Dalvik/ART 缓存..."
rm -rf /data/dalvik-cache/*/system@framework@services.jar* 2>/dev/null
rm -rf /data/dalvik-cache/*/*SystemUI* 2>/dev/null
rm -rf /data/resource-cache/*SystemUI* 2>/dev/null
rm -rf /data/misc/profiles/cur/*/system_server 2>/dev/null
rm -rf /data/misc/profiles/ref/system_server 2>/dev/null
rm -rf /data/misc/profiles/cur/*/com.android.systemui 2>/dev/null
rm -rf /data/misc/profiles/ref/com.android.systemui 2>/dev/null

# 配置权限
ui_print "- 正在配置模块文件系统权限 (0755 / 0644)..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/config.prop" 0 0 0644
[ -f "$MODPATH/system.prop" ] && set_perm "$MODPATH/system.prop" 0 0 0644
[ -d "$MODPATH/webroot" ] && set_perm_recursive "$MODPATH/webroot" 0 0 0755 0644

ui_print "**********************************************"
ui_print "* 安装完成！v1.0 正式版核心特性:             *"
ui_print "*   1. Apple-Style 90% 极黑防烧屏底层遮罩    *"
ui_print "*   2. 亮度锁死 0.0f: 永不反弹的极暗息屏     *"
ui_print "*   3. 骁龙 8 至尊版 1Hz LTPO 硬件驱动降频   *"
ui_print "*   4. WebUI / settings.sh 双通道实时配置    *"
ui_print "* 请重启手机以生效！                         *"
ui_print "**********************************************"
