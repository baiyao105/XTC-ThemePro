use themepro::sys;

mod device;
mod extract;
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

    /// 解压ZIP到目标路径
    Extract {
        /// 路径
        zip_path: String,
        /// 内源路径前缀
        src: String,
        /// 目标目录
        dest: String,
    },

    /// 批量解压ZIP到多个目标路径
    ExtractBatch {
        /// 路径
        zip_path: String,
        /// src1:dest1 src2:dest2 ...
        #[arg(num_args = 1..)]
        mappings: Vec<String>,
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
        Commands::Extract { zip_path, src, dest } => extract::run(&zip_path, &src, &dest),
        Commands::ExtractBatch { zip_path, mappings } => extract::run_batch(&zip_path, &mappings),
        Commands::Gethitokoto { file } => hitokoto::run(file),
        Commands::Getdevice => device::run(&moddir),
        Commands::Getdeviceid { length } => device::run_id(length),
        Commands::Getinstall => install::run(&moddir),
        Commands::Query { field } => query::run(field),
        Commands::Prop { name, files } => prop::run(&name, files),
    }
}
