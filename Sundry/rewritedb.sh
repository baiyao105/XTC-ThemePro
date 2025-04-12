#!/system/bin/sh
# Script by XTC-ThemePro - @baiyao105
MODPATH=$(cd "$(dirname "$0")/../.." && pwd)
theme_db="/data/user/0/com.xtc.theme/databases"
am force-stop com.xtc.theme
mkdir -p ${theme_db}
rm -rf ${theme_db}/theme_package.db
cp -af ${MODPATH}/theme_package.db ${theme_db}/theme_package.db
cp ${MODPATH}/personality_charge.db ${theme_db}/personality_charge.db
chmod 700 ${theme_db}/*