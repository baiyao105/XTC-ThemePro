#!/system/bin/sh
# Script by XTC-ThemePro - @baiyao105
MODPATH=$(cd "$(dirname "$0")/.." && pwd)
theme_db="/data/user/0/com.xtc.theme/databases"
am start com.xtc.theme/.view.SplashActivity
am force-stop com.xtc.theme
mkdir -p "${theme_db}" || true
chmod 755 "${theme_db}"/* || true
rm -rf "${theme_db}/theme_package.db" || true
cp -af "${MODPATH}/theme_package.db" "${theme_db}/theme_package.db" || true
cp -af "${MODPATH}/personality_charge.db" "${theme_db}/personality_charge.db" || true
sleep 3
cp -af "${MODPATH}/theme_package.db" "${theme_db}/theme_package.db" || true
cp -af "${MODPATH}/personality_charge.db" "${theme_db}/personality_charge.db" || true
sleep 5
cp -af "${MODPATH}/theme_package.db" "${theme_db}/theme_package.db" || true
cp -af "${MODPATH}/personality_charge.db" "${theme_db}/personality_charge.db" || true
touch /data/user/0/com.xtc.theme/databases/theme_package.db-journal
touch /data/user/0/com.xtc.theme/databases/personality_charge.db-journal
chmod 700 "/data/user/0/com.xtc.theme/databases/theme_package.db" || true
chmod 700 "/data/user/0/com.xtc.theme/databases/personality_charge.db" || true