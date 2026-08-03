use themepro::{fs, sys, EXIT_ERR};

const DEFAULT_FILES: &[&str] = &["/system/build.prop", "/vendor/build.prop", "/product/build.prop"];

pub fn run(prop_name: &str, files: Option<Vec<String>>) {
    // build.prop
    let targets = files.unwrap_or_else(|| DEFAULT_FILES.iter().map(|s| s.to_string()).collect());

    for path in &targets {
        let value = fs::read_prop(path, prop_name);
        if !value.is_empty() {
            println!("{}", value);
            return;
        }
    }
    // fallback
    let val = sys::getprop(prop_name);
    if !val.is_empty() {
        println!("{}", val);
        return;
    }

    eprintln!("属性未找到: {}", prop_name);
    std::process::exit(EXIT_ERR);
}
