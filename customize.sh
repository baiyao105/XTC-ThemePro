#!/system/bin/sh
# Module Protecter_Install
# Customization script by XTC-ThemePro - @baiyao105
# 不要修改这个文件，除非你知道你在做什么

SKIPUNZIP=1
export SKIPUNZIP=1

get_config() {
	sundry_config="$TMPDIR/config.conf"
	grep -E "^[^#].*=$1=" "$sundry_config" | cut -f2 -d '='
}

_grep_prop() {
	REGEX="s/$1=//p"
	shift
	if [ $# -eq 0 ]; then
		set -- "/system/build.prop" "/vendor/build.prop"
	fi
	sed -n "$REGEX" "$@" 2>/dev/null | head -n 1
}

on_sundry() {
	ui_print "- 正在解压临时文件(*>﹏<*)"
	required_files="
        Sundry/hitokoto
        Sundry/config.conf
        files/personality_charge.db
        files/theme_package.db
        files/theme.apk
        module.prop
    "
	for file in $required_files; do
		unzip -j -o "${ZIPFILE}" "${file}" -d "${TMPDIR}" >&2 || abort "解压安装时文件失败:${file}"
	done
	mkdir -p "/sdcard/Android/baiyao105/ThemePro"
	bindnumber=$(getprop ro.boot.bindnumber)
	chipid=$(getprop ro.boot.xtc.chipid)
	model=$(getprop ro.product.innermodel)
	serverinner=$(getprop persist.sys.serverinner "${model}")
	if [ -z "$serverinner" ]; then
		serverinner="${model}"
	fi
	if [ -z "$chipid" ]; then
		abort "Chipid获取失败"
	fi
	Hwmac=$(cat /sys/class/net/wlan0/address 2>/dev/null || echo "unknown")
	input_string="${bindnumber}${serverinner}${chipid}${Hwmac}"
	hash=$(printf "%s" "$input_string" | sha256sum | awk '{print $1}')
	Ostring=$(echo "$hash" | cut -c1-8)
	log_enabled=$(get_config log)
	log_path=$(get_config log_path)

	if [ "$log_enabled" = "true" ]; then
		Clog=1
		name=协作者
		mkdir -p "${log_path}"
		Flog="${log_path}/install.log"
		echo "=== 安装时log ===" >"${Flog}"
		exec 2>"${Flog}"
		set -x
	else
		Clog=0
		name=小杳喵
		Flog="/dev/null"
	fi
	HOUR=$(date +%H)
	HOUR_NUM=$(echo "$HOUR" | sed 's/^0*//')
	[ -z "$HOUR_NUM" ] && HOUR_NUM=0
	if [ "$HOUR_NUM" -ge 0 ] && [ "$HOUR_NUM" -lt 6 ]; then
		period="凌晨"
	elif [ "$HOUR_NUM" -ge 6 ] && [ "$HOUR_NUM" -lt 12 ]; then
		period="上午"
	elif [ "$HOUR_NUM" -ge 12 ] && [ "$HOUR_NUM" -lt 17 ]; then
		period="下午"
	elif [ "$HOUR_NUM" -ge 17 ] && [ "$HOUR_NUM" -lt 19 ]; then
		period="傍晚"
	else
		period="晚上"
	fi

	hitokoto_file="${TMPDIR}/hitokoto"
	if [ -f "$hitokoto_file" ]; then
		all_texts=$(sed -n 's/.*text:\[\(.*\)\]/\1/p' "$hitokoto_file" | sed 's/","/"\n"/g' | sed 's/^"//;s/"$//')
		total_count=$(echo "$all_texts" | wc -l)
		if [ "$total_count" -gt 0 ]; then
			random_num=$(($(date +%s) % total_count + 1))
			best_text=$(echo "$all_texts" | sed -n "${random_num}p")
		else
			best_text="唔?"
		fi
	else
		best_text="唔?文件未找到...(?"
	fi
	cta=$(getprop ro.product.cta.model)
	cta_ver=$(getprop ro.xtc.ctaversion)
	id=$(grep_prop id "$TMPDIR/module.prop")
	ver=$(grep_prop version "$TMPDIR/module.prop")
	code=$(grep_prop versionCode "$TMPDIR/module.prop")
	imoo_ver=$(grep_prop ro.product.current.softversion)
	produce=$(getprop ro.product.manufacturer)
}
print_modname() {
	ui_print "#####################################################"
	ui_print "ThemePro - ${ver}($code)_${Clog}"
	ui_print "● ${period}好,${name}_${Ostring}!"
	ui_print "~ $best_text"
	ui_print "~ 开始安装q(≧▽≦q)"
	ui_print "#####################################################"
	echo "${ver}" >"/sdcard/Android/baiyao105/ThemePro/version"
	case $model in
	I25) ui_print "- 您的机型: Z7-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	I32) ui_print "- 您的机型: Z8|Z8少年版-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	I20) ui_print "- 您的机型: Z6DFB-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	I25C) ui_print "- 您的机型: Z7A-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	I25D) ui_print "- 您的机型: Z7S-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	ND07) ui_print "- 您的机型: Z8A-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	ND01) ui_print "- 您的机型: Z9|Z9少年版-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	ND03) ui_print "- 您的机型: Z10|Z10少年版-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	ND08) ui_print "- 您的机型: Z11|Z11少年版-${imoo_ver}_${produce}.${cta}(${cta_ver}).${API}" ;;
	*) abort "-  不支持的机型-${model}" ;;
	esac
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
		ui_print "! Magisk版本低于23.0: $MAGISK_VER_CODE，安装终止。"
		abort "!  Magisk版本低于23.0"
	else
		ui_print "- Magisk版本: $MAGISK_VER ($MAGISK_VER_CODE)"
	fi
	for f in /data/adb/modules/*/module.prop; do
		sed -i '/^priority=/d' "$f"
	done
}
sundry_shell() {
	if getprop persist.sys.ostype | grep -q "junior"; then
		ui_print "- 您当前使用的是:青春系统"
	else
		ui_print "- 您当前使用的是:经典系统(非青春系统)"
	fi
	current_versions=$(dumpsys package com.xtc.theme | grep versionCode | awk '{print $1}' | sed 's/versionCode=//' | sort -nr)
	max_version=$(echo "$current_versions" | head -n 1)
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
	if [ -z "$max_version" ] || [ "$max_version" -lt 123020 ]; then
		ui_print "- 个性主题版本过低(${max_version:-无}),正在覆盖升级"
		pm install -r -d -t "$TMPDIR/theme.apk" || echo "- 看起来失败了呢..."
	else
		ui_print "- 个性主题已满足要求($max_version)"
	fi
	ui_print "- 清除缓余文件"
	am force-stop com.xtc.theme 2>/dev/null || true
	rm -rf /sdcard/xtc/themepackage 2>/dev/null || true
	am start com.xtc.theme/.view.SplashActivity >&2 || true
	am force-stop com.xtc.theme 2>/dev/null || true
	ui_print "- 替换数据库ing..."
	theme_db="/data/user/0/com.xtc.theme/databases"
	mkdir -p ${theme_db}
	am force-stop com.xtc.theme 2>/dev/null || true
	cp -af "${TMPDIR}/theme_package.db" "${theme_db}/theme_package.db"
	cp -af "${TMPDIR}/personality_charge.db" "${theme_db}/personality_charge.db"
	chmod 444 "${theme_db}/theme_package.db"
	chmod 444 "${theme_db}/personality_charge.db"
	sleep 2
	pm clear com.xtc.theme >&2 || true
	Modata="/data/adb/modules/${id}"
	echo "*/60 * * * * ${Modata}/Sundry/pre_execute.sh" >"${MODPATH}/root"
	ui_print "- 释放文件"
	ui_print "- 过程比较久,请稍等一小会(≧﹏≦)"
	mkdir -p "${MODPATH}/system"
	mkdir -p "${MODPATH}/Sundry"
	unzip -j -o "${ZIPFILE}" 'module.prop' -d "${MODPATH}" >&2 || abort "解压描述文件时出错"
	[ -f "${MODPATH}/module.prop" ] || abort "module.prop 文件未能成功解压"
	unzip -j -o "${ZIPFILE}" 'files/*' -d "${MODPATH}" >&2 || abort "解压数据库时出错"
	unzip -j -o "${ZIPFILE}" 'Sundry/post-fs-data.sh' -d "${MODPATH}" >&2 || abort "解压脚本时出错"
	unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d "${MODPATH}" >&2 || abort "解压脚本时出错"
	unzip -j -o "${ZIPFILE}" 'action.sh' -d "${MODPATH}" >&2 || abort "解压脚本时出错"
	unzip -o "${ZIPFILE}" 'system/*' -d "${MODPATH}" >&2 || abort "解压挂载文件出错"
	unzip -o "${ZIPFILE}" 'Sundry/*' -d "${MODPATH}" >&2 || abort "解压挂载文件出错"
	[ -f "${MODPATH}/module.prop" ] || abort "module.prop 文件未能成功解压"
	rm -rf "${MODPATH}/theme.apk"
	cmd package compile -m everything-profile -f com.xtc.theme >&2 || true
}
set_permissions() {
	chmod +x "${MODPATH}/Sundry/*" || true
	chmod +x "${MODPATH}/Sundry/rewritedb.sh"
	chmod +x "${MODPATH}/Sundry/themepro.sh"
	chmod +x "${MODPATH}/system/bin/themepro"
	set_perm_recursive "${MODPATH}" 0 0 0755 0644
	set_perm_recursive "${MODPATH}/root" 0 0 0755 0700 || true
	set_perm_recursive "${MODPATH}/Sundry" 0 0 0755 0700 || true
	set_perm_recursive "${MODPATH}/system/bin/themepro" 0 0 0755 0700 || true
	set_perm_recursive "${MODPATH}/Sundry/themepro.sh" 0 0 0755 0700 || true
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
