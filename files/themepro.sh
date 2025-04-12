#!/bin/bash
# Script by XTC-ThemePro - @baiyao105

MODDIR=${0%/*}
function gethitokoto() {
    hitokoto_file="${MODDIR}/Sundry/hitokoto"
    if [[ -f "$hitokoto_file" ]]; then
        best_text=$(grep -oP '(?<=text:\[").*?(?="\])' "$hitokoto_file" | tr ',' '\n' | shuf -n 1 | sed 's/\\//g')
        echo "${best_text}"
    else
        echo ""
    fi
}

function getdevice() {
    bindnumber=$(getprop ro.boot.bindnumber)
    chipid=$(getprop ro.boot.xtc.chipid)
    model=$(_grep_prop ro.product.innermodel)
    serverinner=$(getprop persist.sys.serverinner ${model})
    if [[ -z "$serverinner" ]]; then
        serverinner=${model}
    fi
    if [[ -z "$chipid" ]]; then
        echo "Chipid??????"
        return 1
    fi
    Hwmac=$(cat /sys/class/net/wlan0/address)
    input_string="${bindnumber}${serverinner}${chipid}${Hwmac}"
    hash=$(echo -n "$input_string" | sha256sum | awk '{print $1}')
    Ostring=${hash:0:8}
    current_versions=$(dumpsys package com.xtc.theme | grep versionCode | awk '{print $1}' | sort -nr)
    current_versionNames=$(dumpsys package com.xtc.theme | grep versionName | awk '{print $1}' | sort -nr)
    max_version=$(echo "$current_versions" | head -n 1)
    max_versionName=$(echo "$current_versionNames" | head -n 1)
    
    crontab_time=$(cat "${MODPATH}/crontab_time")
    best_text=$(gethitokoto)
    
    module_version=$(grep_prop version "${MODDIR}/module.prop")
    module_code=$(grep_prop versionCode "${MODDIR}/module.prop")
    
    config_file="${MODDIR}/Sundry/config.conf"
    if [[ -f "$config_file" ]]; then
        log_enabled=$(grep -v '^#' "$config_file" | grep "^log=" | cut -f2 -d '=')
        log_path=$(grep -v '^#' "$config_file" | grep "^log_path=" | cut -f2 -d '=')
    fi
    echo "=================================================================="
    echo "XTC-ThemePro @baiyao105 ???????????"
    echo "??????: ${serverinner}"
    echo "???: ${bindnumber}"
    echo "ChipID: ${chipid}"
    echo "????????: ${Ostring}"
    echo "Crontab???: ${crontab_time}"
    echo "???: ${best_text}"
    echo "?????: ${module_version} (${module_code})"
    echo "??????????: ${max_versionName}"
    echo "??????????code: ${max_version}"
    echo "???????: ??=${log_enabled:-false}, ????=${log_path:-??????}"
    echo "=================================================================="
}

function prop() {
    local prop_value=$(_grep_prop "$1")
    if [[ -n "$prop_value" ]]; then
        echo "${prop_value}"
    else
        echo "?????????: $1"
        return 1
    fi
}

# ????????
_grep_prop() {
    local REGEX="s/$1=//p"
    shift
    local FILES=$@
    [[ -z $FILES ]] && FILES="/system/build.prop /vendor/build.prop /product/build.prop"
    sed -n "$REGEX" $FILES 2>/dev/null | head -n 1
}

# ????????
case "$1" in
    "gethitokoto")
        gethitokoto
        ;;
    "getdrvice")
        getdrvice
        ;;
    "prop")
        if [[ -n "$2" ]]; then
            prop_search "$2"
        else
            echo "Usage: themepro prop <property_name>"
            exit 1
        fi
        ;;
    *)
        echo "Usage: themepro <command>"
        echo "Commands:"
        echo "  gethitokoto - ??????"
        echo "  prop <property_name> - ?????????"
        exit 1
        ;;
esac