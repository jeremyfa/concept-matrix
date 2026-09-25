package app;

import app.DocumentActions;
import app.model.AppModel;
import app.model.DocumentState;
import app.model.UIState;
import app.ui.MatrixTable;
import app.ui.NotePanel;
import kit.App;
import kit.AppOptions;
import wisdom.X;

/**
 * Entry point.
 *
 * Everything generic belongs to `kit` and is not repeated here: the init
 * order, persistence, the theme, the virtual DOM, the keyboard listener, the
 * window chrome, the settings popup. This file holds only what the shell
 * cannot know, which is the model, the storage key and the markup.
 *
 * `implements X` is what lets this class write wisdom markup.
 */
class Main implements X {

    static final AUTHOR_URL = 'https://bsky.app/profile/jeremyfa.bsky.social';

    static function openAuthor(e:js.html.Event):Void {

        e.preventDefault();
        Platform.openUrl(AUTHOR_URL, error -> {
            if (error != null) chrome.message = 'Could not open the link: ' + Std.string(error);
        });

    }

    static function main():Void {

        final model = new AppModel();

        // Made reachable as the ambient `model` before anything renders.
        @:privateAccess Shortcuts._model = model;

        DocumentActions.installShortcuts();

        App.start(({
            model: model,
            // APP_SLUG from project.config.sh.
            storageKey: App.SLUG,
            // A state saved before these existed has no document or layout yet.
            onModelLoaded: () -> {
                if (model.document == null) model.document = new DocumentState();
                if (model.ui == null) model.ui = new UIState();
                model.document.watch(model.matrix);
            },
            // Escape closes an open colour picker first, then the notes panel.
            onEscape: () -> {
                final matrix = model.matrix;
                if (matrix.colorPickerNote != null) {
                    matrix.colorPickerNote = null;
                    return true;
                }
                if (matrix.selectedRow != null) {
                    matrix.clearSelection();
                    return true;
                }
                return false;
            },
            render: () -> {
                '<>
                <div class="h-screen flex flex-col bg-t-background text-t-text">

                    // The file name, centred on the window, and a dot while
                    // there are unsaved changes.
                    <TitleBar centerTitle=${DocumentActions.label() + (model.document.unsaved ? ' •' : '')}>
                        // The title drags the window: TitleBar marks the whole
                        // bar data-tauri-drag-region="deep", so anything that
                        // is not a button moves the window. The button cluster
                        // on the right opts out, so its gaps do not drag either.
                        <div class="flex-1 min-w-0 flex items-center gap-2">
                            <Icon kind=${App.ICON} size=16 display="text-t-accent" />
                            <span class="text-[14px] font-semibold truncate">Concept Matrix</span>
                            <div class="flex-1"></div>
                            <div class="flex items-center gap-1" data-tauri-drag-region="false">
                                <IconButton kind="file-plus"
                                            title=${'New matrix (' + Keys.modifierLabel() + 'N)'}
                                            onpress=${() -> DocumentActions.newMatrix()} />
                                <IconButton kind="folder-open"
                                            title=${'Open (' + Keys.modifierLabel() + 'O)'}
                                            onpress=${() -> DocumentActions.open()} />
                                // Not an IconButton: Save needs the click event,
                                // Option/Alt held turning it into Save As. The
                                // classes are the ones of IconButton.
                                <button type="button"
                                        title=${'Save (' + Keys.modifierLabel() + 'S), ' + (Platform.isMac ? '⌥' : 'Alt') + '-click to Save As'}
                                        aria-label="Save"
                                        class="inline-flex items-center justify-center w-8 h-8 shrink-0 rounded-lg transition-colors text-t-text-muted hover:text-t-text hover:bg-t-surface-2 cursor-pointer"
                                        onclick=${(e) -> DocumentActions.save(e.altKey)}>
                                    <Icon kind="save" size=15 display="" />
                                </button>
                                <IconButton kind="settings"
                                            title=${'Settings (' + Keys.modifierLabel() + ',)'}
                                            onpress=${() -> chrome.settingsOpen = true} />
                            </div>
                        </div>
                    </TitleBar>

                    <div class="flex-1 min-h-0 flex">
                        <div class="flex-1 min-w-0 overflow-auto scrollbar-themed">
                            <div class="min-w-fit flex justify-center p-6">
                                <MatrixTable />
                            </div>
                        </div>
                        // The notes of the selected cell. Always mounted, like
                        // the popups below; "contents" lets the panel sit in
                        // this row as if the wrapper were not there.
                        <div class=${model.matrix.selectedRow != null ? "contents" : "hidden"}>
                            <if ${model.matrix.selectedRow != null}>
                                <NotePanel />
                            </if>
                        </div>
                    </div>

                    // The credit, on the right of the status bar. The link opens
                    // through the platform, so the desktop app sends it to the
                    // browser instead of loading it in its own window.
                    <StatusBar>
                        <span class="shrink-0 [text-box:trim-both_ex_alphabetic]">
                            Created by
                            // The markup drops the space before a tag: the margin puts it back.
                            <a href=${AUTHOR_URL} class="ml-[0.25em] text-t-text hover:underline"
                               onclick=${(e) -> openAuthor(e)}>Jérémy Faivre</a>
                        </span>
                    </StatusBar>

                    // Always mounted, hidden when there is nothing to show: a
                    // stable child count keeps wisdom matching nodes correctly
                    // across renders. The kit opens this on the settings
                    // shortcut and closes it on Escape. Your own settings go
                    // between its tags.
                    <div class=${chrome.settingsOpen ? "" : "hidden"}>
                        <if ${chrome.settingsOpen}>
                            <SettingsPopup />
                        </if>
                    </div>

                    // A separate slot, above the one before it. A question is
                    // usually raised from inside a popup and has to sit on top
                    // of the popup that raised it.
                    <div class=${chrome.dialog != null ? "" : "hidden"}>
                        <if ${chrome.dialog != null}>
                            <DialogPopup />
                        </if>
                    </div>

                </div>
                ';
            }
        } : AppOptions));

    }

}
