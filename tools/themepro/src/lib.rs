pub const EXIT_OK: i32 = 0;
pub const EXIT_ERR: i32 = 1;
pub const EXIT_BAD_ARG: i32 = 2;

pub mod fs {
    use std::path::{Path, PathBuf};

    pub fn data_dir() -> PathBuf {
        PathBuf::from("/sdcard/Android/baiyao105/ThemePro")
    }

    pub fn read_trimmed(path: impl AsRef<Path>) -> String {
        std::fs::read_to_string(path)
            .map(|c| c.trim().to_string())
            .unwrap_or_default()
    }

    pub fn read_prop(path: impl AsRef<Path>, key: &str) -> String {
        if let Ok(content) = std::fs::read_to_string(path) {
            let needle = format!("{}=", key);
            for line in content.lines() {
                if let Some(value) = line.strip_prefix(&needle) {
                    return value.to_string();
                }
            }
        }
        String::new()
    }
}

pub mod sys {
    use std::path::PathBuf;
    use std::process::Command;

    pub const MODDIR: &str = "/data/adb/modules/XTC-ThemePro";

    pub fn getprop(key: &str) -> String {
        Command::new("getprop")
            .arg(key)
            .output()
            .map(|o| String::from_utf8_lossy(&o.stdout).trim().to_string())
            .unwrap_or_default()
    }

    pub fn moddir() -> PathBuf {
        PathBuf::from(MODDIR)
    }
}

pub mod crypto {
    use sha2::{Digest, Sha256};

    pub fn sha256_10(input: &str) -> String {
        sha256_n(input, 10)
    }

    pub fn sha256_n(input: &str, n: usize) -> String {
        let mut hasher = Sha256::new();
        hasher.update(input.as_bytes());
        let result = hasher.finalize();
        let hex_str = hex::encode(result);
        hex_str[..n.min(hex_str.len())].to_string()
    }
}
