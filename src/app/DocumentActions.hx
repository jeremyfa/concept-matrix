package app;

import app.model.MatrixData;
import app.utils.MatrixJson;
import js.html.KeyboardEvent;
import kit.platform.FileFilter;
import kit.platform.FileRef;

/** New, Open and Save: what the title bar buttons and shortcuts do. */
class DocumentActions {

    static final FILTERS:Array<FileFilter> = [{ name: 'Concept Matrix', extensions: ['json'] }];

    static final DEFAULT_FILE_NAME = 'matrix.json';

    public static function newMatrix():Void {

        confirmDiscard(() -> {
            final matrix = new MatrixData();
            matrix.add(matrix.defaultName());
            replace(matrix, null);
        });

    }

    public static function open():Void {

        confirmDiscard(() -> {
            Platform.openTextFile(FILTERS, (error, file) -> {
                if (error != null) {
                    Dialog.alert('Could not open file', Std.string(error));
                    return;
                }
                // Cancelled.
                if (file == null) return;

                var matrix:MatrixData = null;
                try {
                    matrix = MatrixJson.read(file.content);
                }
                catch (message:Dynamic) {
                    Dialog.alert('Could not open file', Std.string(message));
                    return;
                }
                replace(matrix, file.ref);
            });
        });

    }

    /**
     * Writes over the current file when the host can (the desktop app, with
     * a file already chosen). Otherwise, and whenever `forceSaveAs` is set,
     * asks where to save: in a browser that is always a fresh download.
     */
    public static function save(forceSaveAs:Bool):Void {

        final document = model.document;
        final content = MatrixJson.write(model.matrix);
        final ref = document.ref();

        final done = (error:Dynamic, saved:FileRef) -> {
            if (error != null) {
                Dialog.alert('Could not save file', Std.string(error));
                return;
            }
            // Cancelled.
            if (saved == null) return;
            document.setFile(saved);
            document.unsaved = false;
        };

        if (!forceSaveAs && ref != null && ref.isWritableInPlace()) {
            Platform.writeTextFile(ref, content, done);
        }
        else {
            Platform.saveTextFileAs(ref != null ? ref.name : DEFAULT_FILE_NAME, content, FILTERS, done);
        }

    }

    /**
     * Cmd/Ctrl+N, O, S and Shift+S.
     *
     * Not kit bindings: the kit leaves every key to a focused text field, and
     * saving has to work while a note is being typed, before the browser
     * takes Cmd+S for "save page". Listening in the capture phase gets there
     * first. In a browser, Cmd/Ctrl+N never reaches the page: the button does.
     */
    public static function installShortcuts():Void {

        window.addEventListener('keydown', (e:KeyboardEvent) -> {
            final modifier = Platform.isMac ? e.metaKey : e.ctrlKey;
            if (!modifier || e.altKey) return;
            // A dialog or the settings popup is modal.
            if (chrome.dialog != null || chrome.settingsOpen) return;

            switch e.key.toLowerCase() {
                case 's':
                    e.preventDefault();
                    save(e.shiftKey);
                case 'o' if (!e.shiftKey):
                    e.preventDefault();
                    open();
                case 'n' if (!e.shiftKey):
                    e.preventDefault();
                    newMatrix();
                case _:
            }
        }, true);

    }

    /** A label for the title bar: the file name, or "Untitled". */
    public static function label():String {

        final document = model.document;
        return document.fileName != null ? document.fileName : 'Untitled';

    }

    /** Makes `matrix` the current one, belonging to `ref` (null for none). */
    static function replace(matrix:MatrixData, ref:FileRef):Void {

        final document = model.document;
        model.matrix.clearSelection();
        model.matrix = matrix;
        document.setFile(ref);
        document.unsaved = false;
        document.watch(matrix);

    }

    /** Runs `then` right away, or after asking when there are unsaved changes. */
    static function confirmDiscard(then:() -> Void):Void {

        if (!model.document.unsaved) {
            then();
            return;
        }
        Dialog.confirm(
            'Unsaved changes',
            'Changes to the current matrix will be lost.',
            'Continue',
            then,
            'danger'
        );

    }

}
