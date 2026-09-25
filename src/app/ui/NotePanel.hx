package app.ui;

import app.model.Note;
import facile.ReadOnlyArray;
import js.html.MouseEvent;
import js.html.TextAreaElement;
import wisdom.Component;

/** The notes of the selected cell, right of the grid. */
class NotePanel extends Component {

    function render() {

        final matrix = model.matrix;
        final row = matrix.selectedRow;
        final col = matrix.selectedCol;
        final title = row != null && col != null ? row.name + ' → ' + col.name : '';

        // No intersection yet means the cell has no note: only the + shows.
        final intersection = matrix.selectedIntersection;
        final notes:ReadOnlyArray<Note> = intersection != null ? intersection.notes : [];
        final last = notes.length - 1;

        return '<>
            <aside class="note-panel group/panel" style=${{ width: model.ui.notePanelWidth }} aria-label="Notes">
                // Drag the left edge to resize. A 9px grip centred on the border,
                // with a line that shows on hover and while dragging.
                <div class="note-splitter group/splitter" onmousedown=${(e) -> startResize(e)}>
                    <div class=${model.ui.resizingNotePanel ? "note-splitter-line-active" : "note-splitter-line"}></div>
                </div>
                // The title wraps rather than being cut: a long pair of concept
                // names stays readable. The close button stays on the first line.
                <div class="flex items-start gap-2 pl-4 pr-2 py-1.5 shrink-0 border-b border-t-border">
                    <div class="note-panel-title">${title}</div>
                    <IconButton kind="x" title="Close" onpress=${() -> matrix.clearSelection()} />
                </div>
                // The same 12px margin on every side of the notes. Their move
                // controls sit in the left one.
                <div class="flex-1 min-h-0 overflow-y-auto scrollbar-themed flex flex-col gap-2 p-3">
                    <foreach ${notes} ${(index:Int, note:Note) -> '<>
                        <NoteCard note=${note} index=${index} last=${index == last} />
                    '} />
                    // The negative margin lines the + glyph up with the notes.
                    <div class="note-add">
                        <button type="button" class="matrix-icon-button" title="Add note" aria-label="Add note"
                                onclick=${(_) -> addNote()}>
                            <Icon kind="plus" size=14 />
                        </button>
                    </div>
                </div>
            </aside>
        ';

    }

    /** The narrowest the panel gets, and how much of the grid it leaves. */
    static final MIN_WIDTH = 220;
    static final MIN_GRID_WIDTH = 320;

    /**
     * Follows the pointer until release, over the whole document, so the drag
     * keeps up however fast the pointer moves. The width is measured from the
     * right edge of the row holding the grid and the panel.
     */
    function startResize(e:MouseEvent):Void {

        e.preventDefault();
        final ui = model.ui;
        final panel:js.html.Element = (cast e.currentTarget:js.html.Element).parentElement;
        final row = panel.parentElement.parentElement;
        ui.resizingNotePanel = true;
        document.body.style.cursor = 'col-resize';
        document.body.style.userSelect = 'none';

        var onMove:MouseEvent->Void = null;
        var onUp:MouseEvent->Void = null;
        onMove = (move:MouseEvent) -> {
            final rect = row.getBoundingClientRect();
            final max = Math.max(MIN_WIDTH, rect.width - MIN_GRID_WIDTH);
            ui.notePanelWidth = Math.round(Math.max(MIN_WIDTH, Math.min(max, rect.right - move.clientX)));
        };
        onUp = (_:MouseEvent) -> {
            ui.resizingNotePanel = false;
            document.body.style.cursor = '';
            document.body.style.userSelect = '';
            document.removeEventListener('mousemove', cast onMove);
            document.removeEventListener('mouseup', cast onUp);
        };
        document.addEventListener('mousemove', cast onMove);
        document.addEventListener('mouseup', cast onUp);

    }

    function addNote():Void {

        final matrix = model.matrix;
        final note = matrix.addNote(matrix.selectedRow, matrix.selectedCol);
        final index = note.intersection.notes.length - 1;

        // Same as a new concept: wisdom has no after-render hook, so wait a
        // frame for the card to exist, then focus its text.
        window.requestAnimationFrame(_ -> {
            final text:TextAreaElement = cast document.querySelector('textarea[data-note="' + index + '"]');
            if (text != null) text.focus();
        });

    }

}
