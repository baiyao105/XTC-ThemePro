#!/system/bin/sh
MODDIR=${0%/*}
Script="${MODDIR}/Sundry"
echo "喵?"
if [ -d "$Script" ]; then
	${Script}/pre_execute.sh
fi
echo "设备信息(￣y▽,￣)╭ "
themepro getdevice
