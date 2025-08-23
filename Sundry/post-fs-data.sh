#!/sbin/sh
# Script by XTC-ThemePro - @baiyao105
MODDIR=${0%/*}
# cp -af "$MODDIR/theme_package.db" "/data/user/0/com.xtc.theme/databases/theme_package.db"
# cp -af "$MODDIR/personality_charge.db" "/data/user/0/com.xtc.theme/databases/personality_charge.db"
while [ "$(getprop sys.boot_completed)" != "1" ]; do
	sleep 5
done
if [ "$(themepro getinstall)" != "true" ]; then
	am force-stop com.xtc.theme
	sleep 7
	themepro getinstall true
	# cp -af "$MODDIR/theme_package.db" "/data/user/0/com.xtc.theme/databases/theme_package.db"
	# cp -af "$MODDIR/personality_charge.db" "/data/user/0/com.xtc.theme/databases/personality_charge.db"
	touch /data/user/0/com.xtc.theme/databases/theme_package.db-journal
	touch /data/user/0/com.xtc.theme/databases/personality_charge.db-journal
	pm clear com.xtc.theme
fi
best_text=$(themepro gethitokoto)
chmod +x "/system/bin/themepro"
chmod +x "${MODDIR}/themepro.sh"
chmod +x "${MODDIR}/Sundry/rewritedb.sh"
sed -i '/^description=/d' "${MODDIR}/module.prop"
echo "description=🌸 为主题加点新花样 - ●${best_text}" >>"${MODDIR}/module.prop"
