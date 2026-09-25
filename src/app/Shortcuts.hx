package app;

import app.model.AppModel;

/**
 * Ambient accessor for this application's state.
 *
 * `src/app/import.hx` pulls it into every module of this package, so any
 * component can write `model.something` with no import line, exactly as it
 * writes `theme.accent` or `chrome.message` from the shell's own shortcuts.
 *
 * The shell deliberately has no equivalent: it cannot name `AppModel`, and
 * that is what keeps the dependency pointing one way.
 */
class Shortcuts {

    static var _model:AppModel = null;

    /** All application state. Set by `Main` before the first render. */
    public static var model(get, never):AppModel;
    inline static function get_model():AppModel {
        return _model;
    }

}
