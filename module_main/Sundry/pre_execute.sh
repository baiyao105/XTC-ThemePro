#!/system/bin/sh
# Script by XTC-ThemePro - @baiyao105
MODPATH=$(cd "$(dirname "$0")/.." && pwd)
date +"%H:%M:%S" >"${MODPATH}/crontab_time"
best_text=$(themepro gethitokoto)
sed -i '/^description=/d' "${MODPATH}/module.prop"
echo "description=🌸 为主题加点新花样 - ●${best_text}" >>"${MODPATH}/module.prop"
