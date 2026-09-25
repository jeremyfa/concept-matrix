# What this project is called. Everything else is derived.
#
# Read by the kit through scripts/config.mjs and scripts/lib.sh, which apply
# the same defaults on both sides. `npm run check-config` fails if any file
# disagrees with what is here.

# npm package name and artifact filename prefix. kebab-case, no spaces.
# Also becomes the Rust crate name and the Docker image prefix unless
# APP_CRATE_NAME or DOCKER_PREFIX say otherwise.
APP_SLUG="concept-matrix"

# Human-facing name. Drives the Tauri productName, the .app bundle name, the
# window title, and the macOS /Volumes/<name> mount point during DMG builds.
APP_PRODUCT_NAME="Concept Matrix"

# Reverse-DNS bundle identifier: macOS bundle id, Windows registry key, Linux
# .desktop id, and the per-user data directory name on every platform.
#
# CHANGE THIS BEFORE SHIPPING. Getting it wrong is invisible until release,
# then it collides in the macOS Launch Services database and the Windows
# registry, and changing it later orphans every user's settings.
APP_IDENTIFIER="jeremyfa.concept-matrix"

# Haxe entry point. The kit is always the `kit` package; this is yours.
APP_MAIN_CLASS="app.Main"

# Optional, all derived from APP_SLUG when left out:
#   APP_CRATE_NAME    Cargo [package].name           (default: the slug)
#   APP_LIB_NAME      Cargo [lib].name               (default: slug_with_underscores_lib)
#   ARTIFACT_PREFIX   <prefix>-v<version>-<os>.<ext> (default: the slug)
#   DOCKER_PREFIX     builder image and cache names  (default: the slug)
#   APP_HAXE_PACKAGE  your Haxe package              (default: app)
#   WEB_DEV_PORT      npm run dev:web                (default: 5173)

# The app icon: any Lucide icon (https://lucide.dev), by name. `npm run
# generate-icons` draws every desktop icon and the favicon from it, and the
# title bar shows it too. Empty: the icons come from resources/AppIcon.png.
APP_ICON="grid-3x3"
# Background: one colour, or two separated by a space for a top-to-bottom
# gradient. Then the colour of the icon itself.
APP_ICON_BACKGROUND="#6366f1 #4338ca"
APP_ICON_FOREGROUND="#ffffff"
# Stroke width on Lucide's 24-unit grid. A little heavier than the 2 of the
# interface keeps the icon legible at 16px.
APP_ICON_STROKE="2.25"

# Optional itch.io target "<user>/<project>" for `npm run publish-itchio`.
# Empty disables publishing with a helpful message rather than a failure.
ITCH_TARGET=""
