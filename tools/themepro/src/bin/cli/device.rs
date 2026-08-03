use std::path::Path;
use std::process::Command;
use themepro::{crypto, fs, sys, EXIT_ERR};

pub fn run_id(length: usize) {
    let chipid = sys::getprop("ro.boot.xtc.chipid");
    if chipid.is_empty() {
        eprintln!("Chipid获取失败");
        std::process::exit(EXIT_ERR);
    }
    let bindnumber = sys::getprop("ro.boot.bindnumber");
    let model = sys::getprop("ro.product.innermodel");
    let serverinner = {
        let v = sys::getprop("persist.sys.serverinner");
        if v.is_empty() {
            model
        } else {
            v
        }
    };
    let hash = crypto::sha256_n(&format!("{}|{}|{}", chipid, bindnumber, serverinner), length);
    println!("{}", hash);
}

fn parse_dumpsys_versions(output: &str) -> (Vec<String>, Vec<String>) {
    let mut version_codes: Vec<String> = Vec::new();
    let mut version_names: Vec<String> = Vec::new();

    for line in output.lines() {
        let trimmed = line.trim();
        if let Some(val) = trimmed.strip_prefix("versionCode=") {
            version_codes.push(val.to_string());
        }
        if let Some(val) = trimmed.strip_prefix("versionName=") {
            version_names.push(val.to_string());
        }
    }

    version_codes.sort_by_key(|b| std::cmp::Reverse(b.parse::<u64>().unwrap_or(0)));
    version_names.sort();

    (version_codes, version_names)
}

fn read_hitokoto(moddir: &Path) -> String {
    let hitokoto_file = moddir.join("Sundry/hitokoto");
    if !hitokoto_file.exists() {
        return String::new();
    }

    let content = match std::fs::read_to_string(&hitokoto_file) {
        Ok(c) => c,
        Err(_) => return "唔?".to_string(),
    };

    let mut texts: Vec<String> = Vec::new();
    for line in content.lines() {
        if let Some(start) = line.find("text:[") {
            let rest = &line[start + 6..];
            if let Some(end) = rest.find(']') {
                let inner = &rest[..end];
                for part in inner.split("\",\"") {
                    let trimmed = part.trim_matches('"');
                    if !trimmed.is_empty() {
                        texts.push(trimmed.to_string());
                    }
                }
            }
        }
    }

    if texts.is_empty() {
        return String::new();
    }

    let idx = (std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as usize)
        % texts.len();

    texts[idx].clone()
}

pub fn run(moddir: &Path) {
    let chipid = sys::getprop("ro.boot.xtc.chipid");
    if chipid.is_empty() {
        eprintln!("Chipid获取失败");
        std::process::exit(EXIT_ERR);
    }

    let bindnumber = sys::getprop("ro.boot.bindnumber");
    let sn = sys::getprop("persist.sys.xtc.sn");
    let bootcounter = sys::getprop("ro.boot.xtc.bootcounter");
    let model = sys::getprop("ro.product.innermodel");
    let serverinner = {
        let v = sys::getprop("persist.sys.serverinner");
        if v.is_empty() {
            model.clone()
        } else {
            v
        }
    };

    let colorindex = sys::getprop("ro.boot.xtc.colorindex");
    let color = sys::getprop("ro.xtcwatch.color");
    let otype = sys::getprop("persist.sys.ostype");
    let os_suffix = if otype.contains("junior") { "_junior" } else { "_N" };
    let cta_model = sys::getprop("ro.product.cta.model");
    let cmiit = sys::getprop("ro.product.cmiit");
    let model_display = format!(
        "{}-{}.{}{} ({}_{})",
        serverinner, colorindex, color, os_suffix, cta_model, cmiit
    );
    let ostring = crypto::sha256_10(&format!("{}|{}|{}", chipid, bindnumber, serverinner));
    let dumpsys_output = Command::new("dumpsys")
        .args(["package", "com.xtc.theme"])
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).to_string())
        .unwrap_or_default();

    let (version_codes, version_names) = parse_dumpsys_versions(&dumpsys_output);
    let max_version = version_codes.first().map(|s| s.as_str()).unwrap_or("");
    let max_version_name = version_names.first().map(|s| s.as_str()).unwrap_or("");
    let factory_version = version_codes.get(1).map(|s| s.as_str()).unwrap_or("");
    let factory_version_name = version_names.get(1).map(|s| s.as_str()).unwrap_or("");
    let crontab_time_raw = fs::read_trimmed(format!("{}/crontab_time", moddir.to_string_lossy()));
    let crontab_time = if crontab_time_raw.is_empty() {
        "未设置"
    } else {
        crontab_time_raw.as_str()
    };
    let best_text = read_hitokoto(moddir);
    let module_prop = moddir.join("module.prop");
    let module_version = fs::read_prop(&module_prop, "version");
    let module_versioncode = fs::read_prop(&module_prop, "versionCode");
    let sep = "────────────────────────────────────────";
    println!();
    println!("  XTC-ThemePro v{}({})", module_version, module_versioncode);
    println!("  {}", best_text);
    println!();
    println!("  {}", sep);
    println!("  设备信息");
    println!("  {}", sep);
    println!("  型号       {}", model_display);
    println!("  绑定号     {} ({})", bindnumber, sn);
    println!("  ChipID     {}", chipid);
    println!("  设备标识   {}", ostring);
    println!("  启动次数   {}", bootcounter);
    if !crontab_time_raw.is_empty() {
        println!("  Crontab    {}", crontab_time);
    }
    println!();
    println!("  {}", sep);
    println!("  主题版本");
    println!("  {}", sep);
    println!("  当前版本   {}", max_version_name);
    println!("  版本号     {}", max_version);
    if !factory_version.is_empty() && factory_version != max_version {
        println!("  系统内置   {} ({})", factory_version_name, factory_version);
    }
    println!();
}
