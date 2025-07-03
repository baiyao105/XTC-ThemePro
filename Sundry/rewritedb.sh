#!/system/bin/sh
# Script by XTC-ThemePro - @baiyao105
MODPATH=$(cd "$(dirname "$0")/.." && pwd)
theme_db="/data/user/0/com.xtc.theme/databases"
am force-stop com.xtc.theme
cp -af "${MODPATH}/theme_package.db" "${theme_db}/theme_package.db" || true
cp -af "${MODPATH}/personality_charge.db" "${theme_db}/personality_charge.db" || true