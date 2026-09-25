//! This project's desktop entry point.
//!
//! Everything generic, the plugins and the per-platform window chrome, lives in
//! the kit's `wisdom-kit-tauri` crate. Only `generate_context!` has to be here,
//! because it reads THIS crate's tauri.conf.json and embeds THIS project's
//! frontend, so it cannot be expanded anywhere else.
//!
//! To add a Tauri plugin for this project alone, chain it onto the builder
//! before `.run(...)`. To add one for every project, put it in the kit.

pub fn run() {
    wisdom_kit_tauri::builder()
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
