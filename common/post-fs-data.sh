#!/sbin/sh
# Script by XTC-ThemePro - @baiyao105
MODDIR=${0%/*}
# 等待开机
cp $MODDIR/theme_package.db /data/user/0/com.xtc.theme/databases/theme_package.db
cp $MODDIR/personality_charge.db /data/user/0/com.xtc.theme/databases/personality_charge.db
while [ $(getprop sys.boot_completed) -eq "1" ]; do
    sleep 5
done
best_text=$(themepro get.hitokoto)
sh ${MODDIR}/Sundry/rewritedb.sh
sed -i '/^description=/d' ${MODPATH}/module.prop
echo "description=${best_text} 对小天才的主题进行补充;上次crontab时间: 等待运行" >>$file