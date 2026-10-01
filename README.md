# Concept Matrix

A tiny game design tool to study how concepts or mechanics interact with each
other. List your concepts, and write notes at each intersection of the matrix.

[Use it online](https://apps.jeremyfa.com/concept-matrix)

https://github.com/user-attachments/assets/f4684ffa-55ab-4963-bbd9-4f91accf51cc

Made with [Haxe](https://haxe.org), [Wisdom](https://github.com/jeremyfa/wisdom), [Tracker](https://github.com/jeremyfa/tracker) and [Tailwind](https://tailwindcss.com), on top of [wisdom-kit](https://github.com/jeremyfa/wisdom-kit). It runs in a browser or as a desktop app using [Tauri](https://tauri.app).

## Requirements

- [Node.js](https://nodejs.org) 22 (see `.nvmrc`)
- [Haxe](https://haxe.org/download/) 4.3.7 or newer (`brew install haxe` on macOS)
- For the desktop app only: [Rust](https://rustup.rs) and the
  [Tauri prerequisites](https://tauri.app/start/prerequisites/) of your system

## Setup

Clone the repository with submodules and install node dependencies:

```bash
git clone --recurse-submodules https://github.com/jeremyfa/concept-matrix.git
cd concept-matrix
npm install
```

## Running the app

```bash
npm run dev:web      # in the browser
npm run dev          # in a desktop window
```

## Exporting

### Web

```bash
npm run build:release
```

This will generate a regular web export in `dist/web` that you can use on any online host.

### Desktop

Each export writes its files into `dist/bundles`:

```bash
ALLOW_UNSIGNED=1 npm run export mac   # .dmg, from macOS only
npm run export linux                  # .AppImage for x64, needs Docker
npm run export linux arm64            # .AppImage for arm64, needs Docker
npm run export windows                # installer and portable zip
npm run export all                    # everything this machine can build
```

- **macOS** builds only on a Mac. Without `ALLOW_UNSIGNED=1`, the export signs the app with the identity from `.env.signing` (copy `.env.signing.example`), and `npm run sign-mac` then notarizes it.

- **Linux** builds inside Docker, from macOS or Linux. The script starts Docker Desktop if needed and stops it afterwards.

- **Windows** builds natively on Windows (Git Bash with the MSVC build tools), or from macOS and Linux through `cargo-xwin`, which downloads about 1.5 GB of Windows SDK files the first time.

### Releases

Pushing a tag like `v0.2.0` runs the same builds that usually run in CI and creates a draft GitHub release with all the files attached. Bump the version in `package.json` first, then run `npm run sync-version` to copy it into Cargo and Tauri.

## Project layout

The app code:

| path | contents |
|---|---|
| `src/app/Main.hx` | the entry point and the main window layout |
| `src/app/model/` | the data: concepts, intersections, notes, document and UI state |
| `src/app/ui/` | the UI components: the matrix table, the notes panel |
| `src/app/utils/` | helpers, including the JSON file format |
| `src/app.css` | the Tailwind styles |

The rest of the project:

| path | contents |
|---|---|
| `project.config.sh` | the app name, identifier and icon |
| `web/` | the HTML page and the favicon |
| `src-tauri/` | the Tauri glue for the desktop app |
| `lib/wisdom-kit/` | the kit, as a submodule: build scripts, window, theme, UI primitives |

After changing a name in `project.config.sh`, run `npm run sync-config`, then `npm run generate-icons` if you changed the icon. The [wisdom-kit README](https://github.com/jeremyfa/wisdom-kit) explains the rest of the commands and how the code fits together.

## How this project is authored

Many parts of this project are handwritten, and others were made with the help of coding assistants. Either way, every corner of the app is the result of careful software design, for which I take full responsibility.

## Licence

[MIT](LICENSE)
