#!/system/bin/sh
MODDIR=${0%/*}
Script="${MODDIR}/Sundry"
echo "喵?"
echo "重写数据库 ＞﹏＜"
if [ -d "$Script" ]; then
	${Script}/pre_execute.sh
	${Script}/rewritedb.sh
fi
echo "设备信息(￣y▽,￣)╭ "
themepro getdevice
