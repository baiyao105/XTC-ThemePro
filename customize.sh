#!/system/bin/sh
# Module Protecter_Install
# Customization script by XTC-ThemePro - @baiyao105
# 不要修改这个文件，除非你知道你在做什么

SKIPUNZIP=1
export SKIPUNZIP=1
BASE="/sdcard/Android/baiyao105/ThemePro"

extract() {
	unzip -j -oq "${ZIPFILE}" "$1" -d "$2" || abort "- 解压 $1 失败"
}

get_config() {
	grep -E "^[^#].*=$1=" "$TMPDIR/config.conf" | cut -f2 -d '='
}

_grep_prop() {
	REGEX="s/$1=//p"
	shift
	if [ $# -eq 0 ]; then
		set -- "/system/build.prop" "/vendor/build.prop"
	fi
	sed -n "$REGEX" "$@" 2>/dev/null | head -n 1
}

mkdir -p "$BASE"

on_sundry() {
	ui_print "- 正在解压临时文件(*>﹏<*)"
	extract "Sundry/config.conf" "$TMPDIR"
	extract "Sundry/hitokoto" "$TMPDIR"
	extract "files/theme.apk" "$TMPDIR"
	extract "files/Filp/filp_path" "$TMPDIR"
	extract "module.prop" "$TMPDIR"
	extract "files/.version" "$TMPDIR"
	filp_path=$(cat "$TMPDIR/filp_path")
	bindnumber=$(getprop ro.boot.bindnumber)
	chipid=$(getprop ro.boot.xtc.chipid)
	model=$(getprop ro.product.innermodel)
	serverinner=$(getprop persist.sys.serverinner)
	ostype=$(getprop persist.sys.ostype)
	is_junior=$(echo "$ostype" | grep -q "junior" && echo "青春系统" || echo "非青春系统")
	color=$(getprop ro.xtcwatch.color)
	[ -n "$color" ] && color="_$color"
	[ -z "$serverinner" ] && serverinner="$model"
	[ -z "$chipid" ] && abort "Chipid获取失败"
	Hwmac=$(cat /sys/class/net/wlan0/address 2>/dev/null || echo "unknown")
	hash=$(printf "%s" "${bindnumber}${serverinner}${chipid}${Hwmac}" | sha256sum | awk '{print $1}')
	Ostring=${hash:0:8}
	log_enabled=$(get_config log)
	log_path=$(get_config log_path)

	if [ "$log_enabled" = "true" ]; then
		mkdir -p "$log_path"
		Flog="${log_path}/install.log"
		exec 2>"${Flog}"
		set -x
		Clog=1
		name=协作者
	else
		Clog=0
		name=小杳喵
		Flog="/dev/null"
	fi
	# 时间段
	hour=$(date +%H | sed 's/^0*//')
	[ -z "$hour" ] && hour=0
	case $hour in
	0-5) period="凌晨" ;;
	6-11) period="上午" ;;
	12-16) period="下午" ;;
	17-18) period="傍晚" ;;
	*) period="晚上" ;;
	esac
	# 一言
	if [ -f "$TMPDIR/hitokoto" ]; then
		best_text=$(sed -n 's/.*text:\[\(.*\)\]/\1/p' "$TMPDIR/hitokoto" |
			tr ',' '\n' | sed 's/"//g' | shuf -n 1)
	else
		best_text="唔?"
	fi

	cta=$(getprop ro.product.cta.model)
	cta_ver=$(getprop ro.xtc.ctaversion)
	id=$(grep_prop id "$TMPDIR/module.prop")
	ver=$(grep_prop version "$TMPDIR/module.prop")
	code=$(grep_prop versionCode "$TMPDIR/module.prop")
	files_version=$(grep_prop version "$TMPDIR/.version")
	files_date=$(grep_prop date "$TMPDIR/.version")
	imoo_ver=$(grep_prop ro.product.current.softversion)
	produce=$(getprop ro.product.manufacturer)
}

print_modname() {
	ui_print "#####################################################"
	ui_print "ThemePro - ${ver}(${code})_${Clog}"
	ui_print "当前主题包版本: ${files_version}(${files_date})"
	ui_print "● ${period}好,${name}_${Ostring}!"
	ui_print "~ $best_text"
	ui_print "~ 开始安装q(≧▽≦q)"
	ui_print "#####################################################"
	echo "${ver}" >"${BASE}/version"
	details="${imoo_ver}_${produce}${color}.${cta}(${cta_ver}).${API}"
	case "$model" in
	I20) ui_print "- 您的机型: Z6DFB-${details}" ;;
	I25) ui_print "- 您的机型: Z7-${details}" ;;
	I25C) ui_print "- 您的机型: Z7A-${details}" ;;
	I25D) ui_print "- 您的机型: Z7S-${details}" ;;
	I32) ui_print "- 您的机型: Z8|Z8少年版-${details}-${is_junior}" ;;
	ND07) ui_print "- 您的机型: Z8A-${details}" ;;
	ND01) ui_print "- 您的机型: Z9|Z9少年版-${details}-${is_junior}" ;;
	ND03) ui_print "- 您的机型: Z10|Z10少年版-${details}-${is_junior}" ;;
	ND08) ui_print "- 您的机型: Z11|Z11少年版-${details}-${is_junior}" ;;
	*) abort "- 不支持的机型-${model}" ;;
	esac
	if [ "$is_junior" = "青春系统" ]; then
		is_junior="_junior"
	else
		is_junior="_N"
	fi
	# 颜色代号和junior一般都在xtcinfo.
	ui_print "- 机型标识符: preset_{$model}${color}${is_junior}"
}

module_validation() {
	if ! $BOOTMODE; then
		ui_print "! 不支持非标准环境安装"
		ui_print "! 可能会出现非预期中的问题"
		abort "! 非标准环境"
	fi
	if [ "$KSU" = "true" ]; then
		ui_print "- KernelSU 用户空间: $KSU_VER_CODE"
		ui_print "- KernelSU 内核空间: $KSU_KERNEL_VER_CODE"
		ui_print "- [KernelSU]蛤(＃°Д°)?"
	elif [ "$MAGISK_VER_CODE" -lt 23000 ]; then
		ui_print "! Magisk版本低于23.0: $MAGISK_VER_CODE, 安装终止。"
		abort "!  Magisk版本低于23.0"
	else
		ui_print "- Magisk版本: $MAGISK_VER ($MAGISK_VER_CODE)"
	fi
}

sundry_shell() {
	ui_print "- 正在安装个性主题♪(´▽｀)"
	directories="
        /data/adb/modules/theme_ful
        /data/adb/modules/alltheme
    "
	for dir in ${directories}; do
		if [ -d "$dir" ]; then
			touch "$dir/skip_mount"
			touch "$dir/remove"
		fi
	done
	pm install -r -d -t "$TMPDIR/theme.apk" || abort "- 安装失败, 记得检查核心破解哦~"
	pm clear com.xtc.theme

	ui_print "- 释放文件"
	ui_print "- 过程比较久,请稍等一小会(≧﹏≦)"
	Modata="/data/adb/modules/${id}"
	mkdir -p "${MODPATH}/system/bin" "${MODPATH}/Sundry" "${BASE}/Themes" "${MODPATH}/${filp_path}"
	for f in \
		module.prop \
		Sundry/themepro.sh \
		uninstall.sh \
		action.sh; do
		extract "$f" "${MODPATH}"
	done
	unzip -oq "${ZIPFILE}" "system/*" -d "${MODPATH}" || abort "解压system失败"
	unzip -oq "${ZIPFILE}" "Sundry/*" -d "${MODPATH}" || abort "解压挂载文件出错"
	echo "*/60 * * * * ${Modata}/Sundry/pre_execute.sh" >"${MODPATH}/root"
	unzip -oq "${ZIPFILE}" "files/Themes/*" -d "${BASE}" || abort "解压主题文件出错"
	unzip -oq "${ZIPFILE}" "files/Filp/*" -d "${MODPATH}/" || abort "解压Filp文件出错"
	rm -rf "${BASE}/Themes" "${MODPATH}/${filp_path}"
	mv -f "${BASE}/files/Themes" "${BASE}/Themes" || abort "移动主题失败"
	mv -f "${MODPATH}/files/Filp" "${MODPATH}/${filp_path}" || abort "移动Filp失败"
	rm -rf "${BASE}/files" "${MODPATH}/files"
	cmd package compile -m everything-profile -f com.xtc.theme >&2 || true
}

set_permissions() {
	chmod +x "${MODPATH}/themepro.sh"
	chmod +x "${MODPATH}/Sundry/pre_execute.sh"
	chmod +x "${MODPATH}/system/bin/themepro"
	set_perm_recursive "${MODPATH}" 0 0 0755 0644
	set_perm_recursive "${MODPATH}/root" 0 0 0755 0700 || true
	set_perm_recursive "${MODPATH}/Sundry" 0 0 0755 0700
	set_perm_recursive "${MODPATH}/service.sh" 0 0 0755 0700
	set_perm_recursive "${MODPATH}/system/bin/themepro" 0 0 0755 0700
	set_perm_recursive "${MODPATH}/themepro.sh" 0 0 0755 0700
	ui_print "- 安装好啦ヾ(≧▽≦*)o"
	ui_print "- 小贴士: 个性主题应用数据将会重置,可能丢失一些主题,是正常现象哦~"
	ui_print "- 正在努力清理环境中哇 ＞﹏＜"
}

get_user_name() {
	query_result=$(content query --uri content://com.xtc.provider/BaseDataProvider/watchId/1 --projection name 2>/dev/null)

	if [ -z "$query_result" ] || [ "${query_result#*null}" != "$query_result" ]; then
		return 1
	fi
	user_name="${query_result#*name=}"
	user_name="${user_name%%[[:space:]]*}"
	user_name="${user_name%%,*}"
	if [ -n "$user_name" ]; then
		echo "$user_name"
	else
		return 1
	fi
}

hello_user() {
	if user_name=$(get_user_name); then
		ui_print "- 你好，$user_name ヾ(≧▽≦*)o"
	else
		ui_print "- 你好 ＞﹏＜"
	fi
}

hello_user
on_sundry
print_modname
module_validation
sundry_shell
set_permissions
