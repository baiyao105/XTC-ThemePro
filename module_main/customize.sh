#!/system/bin/sh
# Module Protecter_Install
# Customization script by XTC-ThemePro - @baiyao105
# 不要修改这个文件，除非你知道你在做什么

SKIPUNZIP=1
BASE="/sdcard/Android/baiyao105/ThemePro"

extract() {
	unzip -j -oq "${ZIPFILE}" "$1" -d "$2" || abort "- 解压 $1 失败"
}

get_config() {
	grep -F "$1=" "$TMPDIR/config.conf"
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

on_init() {
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
		name="大大杳杳"
	else
		Clog=0
		name="小小杳"
		Flog="/dev/null"
	fi
	# 时间段
	hour=$((10#$(date +%H)))
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
	if user_name=$(get_user_name); then
		name="${name}-${user_name}"
	fi
}

print_modname() {
	ui_print "#####################################################"
	ui_print "ThemePro - ${ver}(${code})_${Clog}"
	ui_print "当前主题包版本: ${files_version}(${files_date})"
	ui_print "● ${period}好,${name} ヾ(≧▽≦*)o!"
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
	ui_print "- 机型标识符: preset_$model${color}${is_junior} @${Ostring}"
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

install_theme() {
	disable_module() {
		[ -d "$1" ] && touch "$1/skip_mount" "$1/remove"
	}
	ui_print "- 正在安装个性主题♪(´▽｀)"

	apk="$TMPDIR/theme.apk"
	chmod 644 "$apk"
	install_ok=0
	last_err=""
	last_err=$(pm install -r -d -t "$apk" 2>&1)
	if [ $? -eq 0 ]; then
		install_ok=1
	fi
	if [ "$install_ok" -eq 0 ] && [ -d "/data/local/tmp" ]; then
		ui_print "- 执行安装(local/tmp路径)"
		cp -f "$apk" "/data/local/tmp/theme_install.apk" 2>/dev/null
		last_err=$(pm install -r -d -t "/data/local/tmp/theme_install.apk" 2>&1)
		if [ $? -eq 0 ]; then
			install_ok=1
		fi
		rm -f "/data/local/tmp/theme_install.apk" 2>/dev/null
	fi
	if [ "$install_ok" -eq 0 ]; then
		ui_print "- 执行安装(session)"
		session_id=$(pm install-create -S "$(wc -c <"$apk" | tr -d ' ')" 2>&1)
		if [ -n "$session_id" ]; then
			real_id=$(echo "$session_id" | grep -o '[0-9]*')
			if [ -n "$real_id" ]; then
				cat "$apk" | pm install-write "$real_id" "base.apk" 2>&1
				last_err=$(pm install-commit "$real_id" 2>&1)
				if [ $? -eq 0 ]; then
					install_ok=1
				else
					pm install-abandon "$real_id" >/dev/null 2>&1
				fi
			else
				last_err="$session_id"
			fi
		fi
	fi
	if [ "$install_ok" -eq 0 ]; then
		ui_print ""
		ui_print "!! 安装时失败"
		ui_print "!! 错误: $last_err"
		ui_print "!! SELinux上下文: $(ls -Z "$apk" 2>/dev/null)"
		abort "- 安装失败, 记得检查核心破解哦~"
	fi

	pm clear com.xtc.theme
	disable_module "/data/adb/modules/theme_ful"
	disable_module "/data/adb/modules/alltheme"
	cmd package compile -m everything-profile -f com.xtc.theme >/dev/null 2>&1 || true
}

on_release() {
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
	unzip -oq "${ZIPFILE}" "system/*" "Sundry/*" -d "${MODPATH}" || abort "解压system/Sundry失败"
	echo "*/60 * * * * ${Modata}/Sundry/pre_execute.sh" >"${MODPATH}/root"
	tmp="${TMPDIR}/files_extract"
	mkdir -p "$tmp"
	unzip -oq "${ZIPFILE}" "files/*" -d "$tmp" || abort "解压files失败"
	mv -f "$tmp/files/Themes/"* "${BASE}/Themes/" 2>/dev/null || true
	mv -f "$tmp/files/Filp/"* "${MODPATH}/${filp_path}/" 2>/dev/null || true
	rm -rf "$tmp"
}

set_permissions() {
	set_perm_recursive "${MODPATH}" 0 0 0755 0644
	set_perm_recursive "${MODPATH}/Sundry" 0 0 0755 0700
	set_perm "${MODPATH}/root" 0 0 0755
	set_perm "${MODPATH}/service.sh" 0 0 0755
	set_perm "${MODPATH}/system/bin/themepro" 0 0 0755
	set_perm "${MODPATH}/themepro.sh" 0 0 0755
}

get_user_name() {
	query_result=$(timeout 5 content query --uri content://com.xtc.provider/BaseDataProvider/watchId/1 --projection name 2>/dev/null) || return 1

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

installer() {
	on_init
	print_modname
	module_validation
	install_theme
	on_release
	set_permissions
	ui_print "- 安装好啦ヾ(≧▽≦*)o"
	ui_print "- 小贴士: 个性主题应用数据将会重置,可能丢失一些主题,是正常现象哦~"
	ui_print "- 正在努力清理环境中哇 ＞﹏＜"
}

installer
