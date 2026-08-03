use std::fs;
use std::io::{BufWriter, Read, Write};
use std::path::Path;
use zip::ZipArchive;

use themepro::EXIT_ERR;

const BUF_SIZE: usize = 64 * 1024;

fn open_archive(zip_path: &str) -> ZipArchive<fs::File> {
    let zip_file = match fs::File::open(zip_path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("无法打开ZIP: {}", e);
            std::process::exit(EXIT_ERR);
        }
    };
    match ZipArchive::new(zip_file) {
        Ok(a) => a,
        Err(e) => {
            eprintln!("ZIP解析失败: {}", e);
            std::process::exit(EXIT_ERR);
        }
    }
}

fn extract_entry(entry: &mut zip::read::ZipFile<'_, impl Read>, dest: &Path, src_prefix: &str) -> bool {
    let entry_name = entry.name().to_string();
    if !entry_name.starts_with(src_prefix) {
        return false;
    }
    let rel_path = match entry_name.strip_prefix(src_prefix) {
        Some(p) => p.trim_start_matches('/'),
        None => return false,
    };
    if rel_path.is_empty() {
        return false;
    }
    let target = dest.join(rel_path);
    if let Some(parent) = target.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent).ok();
        }
    }
    if let Ok(outfile) = fs::File::create(&target) {
        let mut writer = BufWriter::with_capacity(BUF_SIZE, outfile);
        let mut buf = [0u8; BUF_SIZE];
        loop {
            let n = match entry.read(&mut buf) {
                Ok(0) => break,
                Ok(n) => n,
                Err(_) => break,
            };
            writer.write_all(&buf[..n]).ok();
        }
        return true;
    }
    false
}

pub fn run(zip_path: &str, src_prefix: &str, dest: &str) {
    let mut archive = open_archive(zip_path);
    let dest_path = Path::new(dest);
    let mut count = 0;
    for i in 0..archive.len() {
        let mut entry = match archive.by_index(i) {
            Ok(e) => e,
            Err(_) => continue,
        };
        if extract_entry(&mut entry, dest_path, src_prefix) {
            count += 1;
        }
    }
    println!("{}", count);
}

pub fn run_batch(zip_path: &str, mappings: &[String]) {
    let mut archive = open_archive(zip_path);
    let parsed: Vec<(&str, &Path)> = mappings
        .iter()
        .filter_map(|m| {
            let (src, dest) = m.split_once(':')?;
            Some((src, Path::new(dest)))
        })
        .collect();
    if parsed.is_empty() {
        eprintln!("无有效的 src:dest 映射");
        std::process::exit(EXIT_ERR);
    }

    let mut counts: Vec<u32> = vec![0; parsed.len()];
    for i in 0..archive.len() {
        let mut entry = match archive.by_index(i) {
            Ok(e) => e,
            Err(_) => continue,
        };
        for (j, (src, dest)) in parsed.iter().enumerate() {
            if extract_entry(&mut entry, dest, src) {
                counts[j] += 1;
            }
        }
    }

    for (i, (src, _)) in parsed.iter().enumerate() {
        println!("{}:{}", src, counts[i]);
    }
}
