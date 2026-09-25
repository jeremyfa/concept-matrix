package app.model;

import app.NoteColors;
import app.utils.ListUtils;
import facile.ReadOnlyArray;
import kit.model.BaseModel;

class Intersection extends BaseModel {

    @serialize public var matrix:MatrixData;

    @serialize public var row:Concept;

    @serialize public var col:Concept;

    @serialize public var notes:ReadOnlyArray<Note> = [];

    public function new(matrix:MatrixData, row:Concept, col:Concept) {
        super();
        this.matrix = matrix;
        this.row = row;
        this.col = col;
    }

    /**
     * The background of this intersection's cell in the grid: one horizontal
     * band per note, top to bottom in note order, each in its note's colour.
     * Null when there is no note.
     *
     * Computed, so it only reads the notes list and each note's colour: it is
     * rebuilt when those change, never while a note's text is typed, and the
     * grid does not re-render then either.
     */
    @compute public function cellBackground():String {
        final count = notes.length;
        if (count == 0) return null;
        final stops = [];
        for (i in 0...count) {
            final tint = NoteColors.cellTint(notes[i].color);
            stops.push('$tint ${i * 100 / count}% ${(i + 1) * 100 / count}%');
        }
        return 'linear-gradient(to bottom, ' + stops.join(', ') + ')';
    }

    public function addNote(color:String, text:String):Note {

        var notes = [].concat(this.notes);
        final note = new Note(this, color, text);
        notes.push(note);
        this.notes = notes;
        return note;

    }

    /** Swaps `note` with its neighbour `delta` places away (-1 or +1). */
    public function moveNote(note:Note, delta:Int):Void {

        final notes = ListUtils.moved(this.notes, note, delta);
        if (notes != null) this.notes = notes;

    }

    /** Removes `note` from this intersection only. Use MatrixData.removeNote,
        which also drops the intersection once it has no note left. */
    public function removeNote(note:Note):Void {

        var notes = [].concat(this.notes);
        notes.remove(note);
        this.notes = notes;

    }

}
