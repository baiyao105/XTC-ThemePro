use std::fs;
use std::path::PathBuf;

use themepro::sys;

pub fn run(file: Option<String>) {
    let path = match file {
        Some(f) => PathBuf::from(f),
        None => {
            let moddir = sys::moddir();
            moddir.join("Sundry/hitokoto")
        }
    };

    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => {
            println!("唔?文件未找到...(?");
            return;
        }
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
        println!("唔?");
        return;
    }
    let idx = (std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as usize)
        % texts.len();

    println!("{}", texts[idx]);
}
