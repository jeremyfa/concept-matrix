fn main() {
    // Rebuild when an icon changes.
    //
    // tauri-build emits rerun-if-changed for tauri.conf.json, the capabilities
    // and the bundled resources, but NOT for the icons. On macOS `tauri dev`
    // bakes icons/icon.icns into the binary as the Dock icon, through the
    // generate_context! macro, so without this line cargo has no reason to
    // re-expand that macro: you replace the icon, rebuild, and the old one is
    // still there, with nothing to suggest the build was skipped.
    //
    // Watching the directory covers icon.icns, icon.ico and every PNG in one
    // line, and costs nothing when they have not changed.
    println!("cargo:rerun-if-changed=icons");

    // Rebuild when the frontend changes. generate_context! embeds ../dist/web
    // into the binary at compile time, but tauri-build only emits
    // rerun-if-changed for tauri.conf.json, the capabilities and the bundled
    // resources, NOT for frontendDist. Without this line, changing only the
    // frontend leaves cargo with no reason to recompile, so a release build
    // keeps embedding the OLD frontend with nothing to signal it was skipped.
    // (tauri dev is unaffected: it serves dist/web live rather than embedding.)
    println!("cargo:rerun-if-changed=../dist/web");

    tauri_build::build()
}
