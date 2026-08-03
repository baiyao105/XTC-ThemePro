use std::process::Command;
use themepro::{EXIT_BAD_ARG, EXIT_ERR};

fn query_content(uri: &str) -> String {
    Command::new("content")
        .args(["query", "--uri", uri])
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).to_string())
        .unwrap_or_default()
}

fn parse_value(line: &str, key: &str) -> String {
    let needle = format!("{}=", key);
    if let Some(start) = line.find(&needle) {
        let rest = &line[start + needle.len()..];
        let end = rest.find(',').unwrap_or(rest.len());
        let val = rest[..end].trim();
        if val.starts_with('"') && val.ends_with('"') {
            val[1..val.len() - 1].to_string()
        } else {
            val.to_string()
        }
    } else {
        String::new()
    }
}

fn parse_json_field(json: &str, field: &str) -> String {
    let needle = format!("\"{}\":", field);
    if let Some(start) = json.find(&needle) {
        let rest = &json[start + needle.len()..];
        let rest = rest.trim_start();
        if let Some(rest) = rest.strip_prefix('"') {
            if let Some(end) = rest.find('"') {
                return rest[..end].to_string();
            }
        }
        let end = rest.find(|c: char| !c.is_ascii_digit()).unwrap_or(rest.len());
        rest[..end].to_string()
    } else {
        String::new()
    }
}

struct WatchInfo {
    watch_id: String,
    open_id: String,
    account_id: String,
    real_name: String,
    name: String,
    icon: String,
    genius_number: String,
}

fn parse_watch(line: &str) -> WatchInfo {
    let im_account_info = parse_value(line, "imAccountInfo");
    WatchInfo {
        watch_id: parse_value(line, "watchId"),                      // watchid
        open_id: parse_value(line, "openID"),                        // openid
        account_id: parse_json_field(&im_account_info, "accountId"), // accountid
        real_name: parse_value(line, "realName"),                    // 真实名称
        name: parse_value(line, "name"),                             // 昵称
        icon: parse_value(line, "icon"),                             // 头像
        genius_number: parse_value(line, "geniusNumber"),            // 天才号
    }
}

pub fn run(field: Option<String>) {
    let uri = "content://com.xtc.provider/BaseDataProvider/watchId/1";
    let output = query_content(uri);

    if output.is_empty() || output.contains("No result found") {
        eprintln!("查询失败: 未找到数据");
        std::process::exit(EXIT_ERR);
    }

    let line = output.lines().next().unwrap_or("");
    let info = parse_watch(line);

    match field.as_deref() {
        Some("watchId") | Some("watchid") => println!("{}", info.watch_id),
        Some("openID") | Some("openid") => println!("{}", info.open_id),
        Some("accountId") | Some("accountid") => println!("{}", info.account_id),
        Some("realName") | Some("realname") => println!("{}", info.real_name),
        Some("name") => println!("{}", info.name),
        Some("icon") => println!("{}", info.icon),
        Some("geniusNumber") | Some("geniusnumber") => println!("{}", info.genius_number),
        Some(f) => {
            eprintln!("未知字段: {}", f);
            eprintln!("可用字段: watchId, openID, accountId, realName, name, icon, geniusNumber");
            std::process::exit(EXIT_BAD_ARG);
        }
        None => {
            println!("watchId:      {}", info.watch_id);
            println!("openID:       {}", info.open_id);
            println!("accountId:    {}", info.account_id);
            println!("真实名称:      {}", info.real_name);
            println!("昵称:         {}", info.name);
            println!("头像:         {}", info.icon);
            println!("天才号:       {}", info.genius_number);
        }
    }
}
