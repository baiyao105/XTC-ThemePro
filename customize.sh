#!/bin/bash
# XTC-ThemePro V0.8.1
# Module Protecter_Install
# Customization script by XTC-ThemePro - @baiyao105
# 不要修改这个文件，除非你知道你在做什么

SKIPUNZIP=1
export SKIPUNZIP=1

# 获取配置值
function get_config() {
    local sundry_config="$TMPDIR/config.conf"
    grep -E "^[^#].*=$1=" "$sundry_config" | cut -f2 -d '='
}

_grep_prop() {
    local REGEX="s/$1=//p"
    shift
    local FILES=("$@")    
    if [[ ${#FILES[@]} -eq 0 ]]; then
        FILES=("/system/build.prop" "/vendor/build.prop" "/product/build.prop")
    fi
    sed -n "$REGEX" "${FILES[@]}" 2>/dev/null | head -n 1
}

on_sundry() {
    ui_print "- 正在解压临时文件(*>﹏<*)"
    # 必需的文件列表
    required_files="
        Sundry/hitokoto
        Sundry/config.conf
        files/theme_package.db
        files/personality_charge.db
        common/theme12150.apk
        module.prop
    "
    for file in $required_files; do
        unzip -j -o "${ZIPFILE}" "${file}" -d "${TMPDIR}" || abort "解压安装时文件失败:${file}"
    done

    echo "0.8.1" > "/sdcard/Android/baiyao105/ThemePro"
    mkdir -p "/sdcard/Android/baiyao105/ThemePro"

    bindnumber=$(getprop ro.boot.bindnumber)
    chipid=$(getprop ro.boot.xtc.chipid)
    model=$(_grep_prop ro.product.innermodel)
    serverinner=$(getprop persist.sys.serverinner "${model}")
    if [[ -z "$serverinner" ]]; then
        serverinner="${model}"
    fi
    if [[ -z "$chipid" ]]; then
        abort "Chipid获取失败"
    fi
    Hwmac=$(cat /sys/class/net/wlan0/address)
    input_string="${bindnumber}${serverinner}${chipid}${Hwmac}"
    hash=$(echo -n "$input_string" | sha256sum | awk '{print $1}')
    Ostring=${hash:0:8}
    log_enabled=$(get_config log)
    log_path=$(get_config log_path)

    if [[ "$log_enabled" == "true" ]]; then
        Clog=1
        name=开发/测试者
        mkdir -p "${log_path}"
        Flog="${log_path}/install.log"
        echo "=== 安装时log ===" > "${Flog}"
        exec 2>"${Flog}"
        set -x
    else
        Clog=0
        name=同学
        Flog="/dev/null"
    fi

    HOUR=$(date +%H)
    if [ $((10#$HOUR)) -ge 0 ] && [ $((10#$HOUR)) -lt 6 ]; then
      period="凌晨"
    elif [ $((10#$HOUR)) -ge 6 ] && [ $((10#$HOUR)) -lt 12 ]; then
      period="上午"
    elif [ $((10#$HOUR)) -ge 12 ] && [ $((10#$HOUR)) -lt 17 ]; then
      period="下午"
    elif [ $((10#$HOUR)) -ge 17 ] && [ $((10#$HOUR)) -lt 19 ]; then
      period="傍晚"
    else
      period="晚上"
    fi

    hitokoto_file="${TMPDIR}/hitokoto"
    best_text=$(grep -oP '(?<=text:\[").*?(?="\])' "$hitokoto_file" | tr ',' '\n' | shuf -n 1 | sed 's/\\//g')
    cta=$(grep_prop ro.product.cta.model)
    ver=$(grep_prop version "$TMPDIR/module.prop")
    code=$(grep_prop versionCode "$TMPDIR/module.prop")
    imoo_ver=$(grep_prop ro.product.current.softversion)
    produce=$(grep_prop ro.product.manufacturer)
}
print_modname() {
    ui_print "#####################################################"
    ui_print "ThemePro - ${ver}($code)_${Clog}"
    ui_print "● ${period}好,${name}_${Ostring}!"
    ui_print "~ $best_text"
    ui_print "~ 开始安装q(≧▽≦q)"
    ui_print "#####################################################"
    case $model in
        I25)    ui_print "- 您的机型: Z7-${imoo_ver}_${produce}.${cta}.${API}" ;;
        I32)    ui_print "- 您的机型: Z8|Z8少年版-${imoo_ver}_${produce}.${cta}.${API}" ;;
        I20)    ui_print "- 您的机型: Z6DFB-${imoo_ver}_${produce}.${cta}.${API}";;
        I25C)   ui_print "- 您的机型: Z7A-${imoo_ver}_${produce}.${cta}.${API}" ;;
        I25D)   ui_print "- 您的机型: Z7S-${imoo_ver}_${produce}.${cta}.${API}" ;;
        ND07)   ui_print "- 您的机型: Z8A-${imoo_ver}_${produce}.${cta}.${API}" ;;
        ND01)   ui_print "- 您的机型: Z9|Z9少年版-${imoo_ver}_${produce}.${cta}.${API}" ;;
        ND03)   ui_print "- 您的机型: Z10-${imoo_ver}_${produce}.${cta}.${API}";;
        *) abort "-  不支持的机型-${model}" ;;
    esac
}
module_validation(){
    if ! $BOOTMODE; then
        ui_print "! 不支持非标准环境安装"
        ui_print "! 可能会出现非预期中的问题"
        abort "! 非标准环境"
    fi
    if [[ "$KSU" == "true" ]]; then
      ui_print "- KernelSU 用户空间: $KSU_VER_CODE"
      ui_print "- KernelSU 内核空间: $KSU_KERNEL_VER_CODE"
      ui_print "- [KernelSU]蛤(＃°Д°)?"
    elif [ "$MAGISK_VER_CODE" -lt 23000 ];then
        ui_print "! Magisk版本低于23.0: $MAGISK_VER_CODE，安装终止。" 
        abort "!  Magisk版本低于23.0" 
    else
        ui_print " - Magisk版本: $MAGISK_VER ($MAGISK_VER_CODE)"
    fi
    if [ "$API" -ne 27 ]; then
    ui_print "! 安卓版本不兼容: ${API}，安装终止。"
    abort "! 设备SDK应为27 (Android 8.1)"
    fi
    for f in /data/adb/modules/*/module.prop; do
        sed -i '/^priority=/d' "$f"
    done
}
sundry_shell(){
    # 检查主题应用版本号
    current_versions=$(dumpsys package com.xtc.theme | grep versionCode | awk '{print $1}' | sort -nr)
    max_version=$(echo "$current_versions" | head -n 1)
    if [ -z "$max_version" ] || [ "$max_version" -lt 12150 ]; then
        ui_print "- 个性主题版本过低(${max_version:-无}),正在覆盖升级"
        pm install -r -d -t "$TMPDIR/theme12150.apk"
    else
        ui_print "- 个性主题已满足要求($max_version)"
    fi
    ui_print "- 清除缓余文件"
    am force-stop com.xtc.theme
    rm -rf /sdcard/xtc/themepackage
    rm -r /data/user/0/com.xtc.xws
    pm clear com.xtc.theme
    am force-stop com.xtc.theme
    ui_print "- 替换数据库"
    theme_db="/data/user/0/com.xtc.theme/databases"
    mkdir -p ${theme_db}
    rm -rf "${theme_db}/theme_package.db"
    cp -af "${TMPDIR}/theme_package.db" "${theme_db}/theme_package.db"
    cp "${TMPDIR}/personality_charge.db" "${theme_db}/personality_charge.db"
    set_perm_recursive ${theme_db} 0 0 0755 0400 || true
    chmod 700 ${theme_db}/*
    echo "*/60 * * * * ${MODPATH}/Sundry/pre_execute.sh && ${MODPATH}/Sundry/rewritedb.sh" >"${MODPATH}/root"
    ui_print "- 释放文件"
    ui_print "- 过程比较久,请稍等一小会(≧﹏≦)"
    mkdir -p "${MODPATH}/system"
    mkdir -p "${MODPATH}/Sundry"
    # 确保先解压module.prop文件
    unzip -j -o "${ZIPFILE}" 'module.prop' -d "${MODPATH}" >&2 || abort "解压描述文件时出错"
    [ -f "${MODPATH}/module.prop" ] || abort "module.prop 文件未能成功解压"
    unzip -j -o "${ZIPFILE}" 'files/*' -d "${MODPATH}" >&2 || abort "解压数据库时出错"
    unzip -j -o "${ZIPFILE}" 'common/post-fs-data.sh' -d "${MODPATH}" >&2 || abort "解压脚本时出错"
    unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d "${MODPATH}" >&2 || abort "解压脚本时出错"
    unzip -j -o "${ZIPFILE}" 'system/*' -d "${MODPATH}"/system >&2 || abort "解压挂载文件出错"
    unzip -j -o "${ZIPFILE}" 'Sundry/*' -d "${MODPATH}"/Sundry >&2 || abort "解压挂载文件出错"
    [ -f "${MODPATH}/module.prop" ] || abort "module.prop 文件未能成功解压"
    ui_print "- 安装好啦ヾ(≧▽≦*)o"
}
set_permissions() {
  chmod +x "${MODPATH}/Sundry/rewritedb.sh"
  chmod +x "${MODPATH}/system/bin/themepro.sh"
  set_perm_recursive  "${MODPATH}"  0  0  0755  0644
}

# 主执行流程
print_modname
module_validation
on_sundry
sundry_shell