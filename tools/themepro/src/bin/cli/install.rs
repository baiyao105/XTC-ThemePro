use std::path::Path;
use themepro::fs;

pub fn run(moddir: &Path) {
    let data_dir = themepro::fs::data_dir();
    let version_file = data_dir.join("version");
    if !version_file.exists() {
        println!("未安装");
        return;
    }
    let version = fs::read_trimmed(&version_file);
    let module_prop = moddir.join("module.prop");
    let module_version = fs::read_prop(&module_prop, "version");
    if version.is_empty() {
        println!("已安装 (版本未知)");
    } else if version == module_version {
        println!("已安装 (版本一致)");
    } else {
        println!("已安装 (data: {}, 模块: {})", version, module_version);
    }
}
