use std::{env, fs, path::PathBuf};
use xdgen::{App, Context, FluentString};

fn main() {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let i18n_dir = PathBuf::from(&manifest_dir).join("i18n");
    let id = "io.github.cosmic-guake-term";
    let ctx = Context::new(&i18n_dir, env::var("CARGO_PKG_NAME").unwrap_or_else(|_| "cosmic-guake-term".to_string())).unwrap();
    let app = App::new(FluentString("cosmic-terminal"))
        .comment(FluentString("comment"))
        .keywords(FluentString("keywords"));
    let output = PathBuf::from(&manifest_dir).join("target/xdgen");
    fs::create_dir_all(&output).unwrap();
    fs::write(
        output.join(format!("{}.desktop", id)),
        app.expand_desktop(format!("res/{}.desktop", id), &ctx)
            .unwrap(),
    )
    .unwrap();
    fs::write(
        output.join(format!("{}.metainfo.xml", id)),
        app.expand_metainfo(format!("res/{}.metainfo.xml", id), &ctx)
            .unwrap(),
    )
    .unwrap();
}
