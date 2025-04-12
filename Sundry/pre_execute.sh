#!/system/bin/sh
# Script by XTC-ThemePro - @baiyao105
MODPATH=$(cd "$(dirname "$0")/../.." && pwd)
date +"%H:%M:%S" > ${MODPATH}/crontab_time
best_text=$(themepro get.hitokoto)
sed -i '/^description=/d' ${MODPATH}/module.prop
echo "description=${best_text} 对小天才的主题进行补充;上次crontab时间: "$(cat "${MODPATH}/crontab_time")" " >>$file