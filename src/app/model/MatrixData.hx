package app.model;

import app.NoteColors;
import app.utils.ListUtils;
import facile.ReadOnlyArray;
import kit.model.BaseModel;

class MatrixData extends BaseModel {

    @serialize public var concepts:ReadOnlyArray<Concept> = [];

    @serialize public var intersections:ReadOnlyArray<Intersection> = [];

    /** A → B and B → A show the same notes, under the title "A + B". Only
        changes what is shown and where new notes go: the notes of both
        directions stay in `intersections`, and show again once it is off. */
    @serialize public var symmetric:Bool = false;

    /** The cell whose notes are shown. Not saved: a selection belongs to a
        session, not to the document. */
    @observe public var selectedRow:Concept = null;

    @observe public var selectedCol:Concept = null;

    /** The cell under the mouse, in symmetric mode only, so the other cell of
        its pair lights up with it. Not saved either. */
    @observe public var hoveredRow:Concept = null;

    @observe public var hoveredCol:Concept = null;

    /** The note whose colour picker is open, if any. Not saved either. */
    @observe public var colorPickerNote:Note = null;

    public function new() {
        super();
    }

    /** Intersections by row then column, rebuilt only when the list changes,
        so the grid does not search the whole list for each of its cells. */
    @compute public function intersectionMap():Map<Concept, Map<Concept, Intersection>> {
        final map = new Map<Concept, Map<Concept, Intersection>>();
        for (intersection in intersections) {
            var cols = map.get(intersection.row);
            if (cols == null) {
                cols = new Map();
                map.set(intersection.row, cols);
            }
            cols.set(intersection.col, intersection);
        }
        return map;
    }

    /** The intersection of the selected cell, or null when nothing is selected
        or the cell has no note yet. */
    @compute public function selectedIntersection():Intersection {
        return selectedRow != null && selectedCol != null ? cell(selectedRow, selectedCol) : null;
    }

    /** The intersection the cell `row` × `col` shows, or null when it shows no
        note. The intersection of that very cell, except in symmetric mode,
        where both cells of a pair show the one in the lower half (the row
        below the column), or the other one when the lower half has no note.
        Falling back keeps notes in view when reordering moves them to the
        upper half. */
    public function cell(row:Concept, col:Concept):Intersection {

        if (!symmetric || row == col) return intersection(row, col);

        final lower = isLower(row, col);
        final shown = lower ? intersection(row, col) : intersection(col, row);
        if (shown != null) return shown;
        return lower ? intersection(col, row) : intersection(row, col);

    }

    /** Whether the cell `row` × `col` is in the lower half of the grid. */
    public function isLower(row:Concept, col:Concept):Bool {

        return concepts.indexOf(row) > concepts.indexOf(col);

    }

    /** The intersection of `row` and `col`, or null when it has no note. */
    public function intersection(row:Concept, col:Concept):Intersection {

        final cols = intersectionMap.get(row);
        return cols != null ? cols.get(col) : null;

    }

    public function add(name:String):Concept {

        var concepts = [].concat(this.concepts);
        final concept = new Concept(this, name);
        concepts.push(concept);
        this.concepts = concepts;
        return concept;

    }

    /** Swaps `concept` with its neighbour `delta` places away (-1 or +1). */
    public function move(concept:Concept, delta:Int):Void {

        final concepts = ListUtils.moved(this.concepts, concept, delta);
        if (concepts != null) this.concepts = concepts;

    }

    /** Removes `concept`, along with the intersections that involve it. The
        matrix always keeps at least one concept: removing the last one does
        nothing. */
    public function remove(concept:Concept):Void {

        if (this.concepts.length <= 1) return;

        var concepts = [].concat(this.concepts);
        concepts.remove(concept);
        this.concepts = concepts;

        this.intersections = this.intersections.filter(i -> i.row != concept && i.col != concept);

        if (selectedRow == concept || selectedCol == concept) clearSelection();

    }

    public function select(row:Concept, col:Concept):Void {

        selectedRow = row;
        selectedCol = col;
        colorPickerNote = null;

    }

    public function clearSelection():Void {

        selectedRow = null;
        selectedCol = null;
        colorPickerNote = null;

    }

    /** Adds a note to the cell `row` × `col`, creating its intersection on the
        first note. The note starts with the default colour. In symmetric mode
        it goes to the intersection the cell shows, or to a new one in the
        lower half. */
    public function addNote(row:Concept, col:Concept, text:String = ''):Note {

        var intersection = cell(row, col);
        if (intersection == null) {
            if (symmetric && !isLower(row, col)) {
                final upper = row;
                row = col;
                col = upper;
            }
            intersection = new Intersection(this, row, col);
            var intersections = [].concat(this.intersections);
            intersections.push(intersection);
            this.intersections = intersections;
        }
        return intersection.addNote(NoteColors.DEFAULT, text);

    }

    /** Removes `note`, and its intersection once it has no note left: an
        intersection only exists while it holds notes. */
    public function removeNote(note:Note):Void {

        // Already gone when Shift+Backspace deleted it and the blur of its
        // removed field follows.
        final intersection = note.intersection;
        if (intersection.notes.indexOf(note) == -1) return;

        intersection.removeNote(note);
        if (colorPickerNote == note) colorPickerNote = null;

        if (intersection.notes.length == 0) {
            var intersections = [].concat(this.intersections);
            intersections.remove(intersection);
            this.intersections = intersections;
        }

    }

    /** The name given to a new concept, or to the last remaining one when its
        name is emptied. */
    public function defaultName():String {

        return '_';

    }

}
