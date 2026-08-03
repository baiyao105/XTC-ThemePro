use themepro::sys;

mod device;
mod hitokoto;
mod install;
mod prop;
mod query;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "themepro", version, about = "XTC-ThemePro CLI tool")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 获取一言
    Gethitokoto {
        /// 自定义hitokoto文件路径
        file: Option<String>,
    },

    /// 设备信息
    Getdevice,

    /// 标识符
    Getdeviceid {
        /// 标识符长度（默认10）
        #[arg(short, long, default_value_t = 10)]
        length: usize,
    },

    /// 安装状态
    Getinstall,

    /// 某data
    Query {
        /// 字段名（不指定则显示全部）
        field: Option<String>,
    },

    /// 获取prop
    Prop {
        /// 属性名
        name: String,

        /// 自定义 build.prop 文件路径
        #[arg(short, long, num_args = 1..)]
        files: Option<Vec<String>>,
    },
}

fn main() {
    let cli = Cli::parse();
    let moddir = sys::moddir();

    match cli.command {
        Commands::Gethitokoto { file } => hitokoto::run(file),
        Commands::Getdevice => device::run(&moddir),
        Commands::Getdeviceid { length } => device::run_id(length),
        Commands::Getinstall => install::run(&moddir),
        Commands::Query { field } => query::run(field),
        Commands::Prop { name, files } => prop::run(&name, files),
    }
}
