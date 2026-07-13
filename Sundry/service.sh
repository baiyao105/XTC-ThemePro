#!/system/bin/sh
# Script by XTC-ThemePro - @baiyao105
MODDIR=${0%/*}
Script="${MODDIR}/Sundry"
chmod +x "${MODDIR}/system/bin/themepro"
chmod +x "${MODDIR}/themepro.sh"
if [ -d "$Script" ]; then
	chmod +x "${Script}/pre_execute.sh"
	"${Script}/pre_execute.sh"
fi
