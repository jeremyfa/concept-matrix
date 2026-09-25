package app.ui;

import app.NoteColors;
import app.model.Note;
import js.html.Element;
import js.html.Event;
import js.html.TextAreaElement;
import wisdom.Component;

/**
 * One note: its text, always editable, on its colour's tint.
 *
 * The move controls, the trash and the colour dot show while the note is
 * hovered or edited. Pressing them does not take the focus from the text
 * (mousedown is cancelled), otherwise leaving an empty note to pick its colour
 * first would delete it on blur.
 */
class NoteCard extends Component {

    @props var note:Note = null;

    @props var index:Int = 0;

    @props var last:Bool = false;

    function render() {

        final matrix = model.matrix;

        final pickerOpen = matrix.colorPickerNote == note;

        return '<>
            <div class="note-row group">
                // In the left margin of the panel, so the note lines up with the
                // panel title.
                <div class="note-reveal note-moves">
                    <button type="button" class="note-icon-button" title="Move up" aria-label="Move up"
                            disabled=${index == 0} onmousedown=${(e) -> keepFocus(e)}
                            onclick=${(_) -> note.intersection.moveNote(note, -1)}>
                        <Icon kind="chevron-up" size=12 />
                    </button>
                    <button type="button" class="note-icon-button" title="Move down" aria-label="Move down"
                            disabled=${last} onmousedown=${(e) -> keepFocus(e)}
                            onclick=${(_) -> note.intersection.moveNote(note, 1)}>
                        <Icon kind="chevron-down" size=12 />
                    </button>
                </div>
                <div class="note-card" style=${{ backgroundColor: NoteColors.noteTint(note.color), borderColor: NoteColors.cellTint(note.color) }}>
                    <div class="note-grow">
                        // Invisible copy of the text that sizes the textarea.
                        // The trailing space keeps a last empty line tall.
                        <div class="note-mirror" aria-hidden="true">${note.text + ' '}</div>
                        <textarea class="note-text" rows="1" data-note=${index} placeholder="…"
                                  aria-label="Note text" value=${note.text}
                                  oninput=${(e) -> write(e)}
                                  onblur=${(_) -> trimText()}></textarea>
                    </div>
                    // The trash, and under it a dot of the current colour that
                    // opens the palette. They stay shown while it is open.
                    // Each button fades in by itself, never their column: a
                    // column below full opacity would cut the trash off from the
                    // note behind it, and its soft-light blend would show opaque
                    // until the fade ends.
                    <div class="note-tools">
                        <button type="button" class=${pickerOpen ? "note-tool" : "note-tool note-reveal"}
                                title="Delete note" aria-label="Delete note"
                                onclick=${(_) -> matrix.removeNote(note)}>
                            <Icon kind="trash-2" size=13 />
                        </button>
                        <button type="button" class=${pickerOpen ? "note-tool-small" : "note-tool-small note-reveal"}
                                title="Color" aria-label="Color"
                                onmousedown=${(e) -> keepFocus(e)}
                                onclick=${(e) -> togglePicker(e)}>
                            <span class="note-dot" style=${{ backgroundColor: note.color }}></span>
                        </button>
                        <if ${pickerOpen}>
                            <div class="note-palette">
                                <foreach ${NoteColors.PALETTE} ${(_:Int, color:String) -> '<>
                                    <button type="button" class=${color == note.color ? "note-swatch note-swatch-active" : "note-swatch"}
                                            style=${{ backgroundColor: color, color: color }} aria-label=${"Color " + color}
                                            onmousedown=${(e) -> keepFocus(e)}
                                            onclick=${(_) -> pick(color)}></button>
                                '} />
                            </div>
                        </if>
                    </div>
                </div>
            </div>
        ';

    }

    function write(e:Event):Void {

        final text:TextAreaElement = cast e.target;
        note.text = text.value;

    }

    /** Trims the text once it is left. An empty note stays: notes are only
        deleted with their trash. */
    function trimText():Void {

        final trimmed = StringTools.trim(note.text);
        if (trimmed != note.text) note.text = trimmed;

    }

    /**
     * Opens or closes the palette. While it is open, pressing anywhere
     * outside this note's trash, dot and palette closes it: another note, the
     * grid, the rest of the panel.
     */
    function togglePicker(e:Event):Void {

        final matrix = model.matrix;
        if (matrix.colorPickerNote == note) {
            matrix.colorPickerNote = null;
            return;
        }
        matrix.colorPickerNote = note;

        // The column holding the dot and the palette. Listening in the capture
        // phase sees the press before anything it lands on can act on it.
        final tools:Element = (cast e.currentTarget:Element).parentElement;
        var onPress:Event->Void = null;
        onPress = (press:Event) -> {
            if (tools.contains(cast press.target)) return;
            document.removeEventListener('mousedown', onPress, true);
            if (matrix.colorPickerNote == note) matrix.colorPickerNote = null;
        };
        document.addEventListener('mousedown', onPress, true);

    }

    function pick(color:String):Void {

        note.color = color;
        model.matrix.colorPickerNote = null;

    }

    function keepFocus(e:Event):Void {

        e.preventDefault();

    }

}
