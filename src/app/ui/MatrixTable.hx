package app.ui;

import app.utils.MatrixLayoutUtils;
import app.model.Concept;
import js.html.Event;
import js.html.InputElement;
import js.html.KeyboardEvent;
import wisdom.Component;

class MatrixTable extends Component {

    function render() {

        final concepts = model.matrix.concepts;
        final last = concepts.length - 1;

        // Header height, right margin and label width fit the longest name.
        var textWidth = 0.0;
        for (concept in concepts) {
            textWidth = Math.max(textWidth, MatrixLayoutUtils.measure(concept.name));
        }
        final headHeight = MatrixLayoutUtils.headHeight(textWidth);
        final overhang = MatrixLayoutUtils.overhang(headHeight);
        final labelMaxWidth = MatrixLayoutUtils.labelMaxWidth(headHeight);

        // Every name field gets the same width, so the column stays put when
        // moving from one to another. +2 leaves room for the caret.
        final nameWidth = Math.ceil(Math.min(textWidth, MatrixLayoutUtils.MAX_TEXT)) + 2;

        // Where the selected cell is, found once rather than for every cell.
        // -1 when nothing is selected.
        final selectedRow = concepts.indexOf(model.matrix.selectedRow);
        final selectedCol = concepts.indexOf(model.matrix.selectedCol);

        return '<>
            <table class="matrix-table group/matrix" style=${{ marginRight: overhang }}>
                <tr>
                    <td class="matrix-gutter"></td>
                    <td class="p-0"></td>
                    <foreach ${concepts} ${(_:Int, concept:Concept) -> '<>
                        <th class="matrix-head" style=${{ height: headHeight }}>
                            <div class=${model.matrix.selectedCol == concept ? "matrix-slant-selected" : "matrix-slant"}></div>
                            <div class=${model.matrix.selectedCol == concept ? "matrix-label-selected" : "matrix-label"}
                                 style=${{ maxWidth: labelMaxWidth }} title=${concept.name}>${concept.name}</div>
                        </th>
                    '} />
                </tr>
                // The slants have no bottom side: the first data row closes
                // the joint with a border-t.
                <foreach ${concepts} ${(row:Int, concept:Concept) -> '<>
                    <tr class="group">
                        <td class="matrix-gutter">
                            <div class="matrix-moves">
                                <button type="button" class="matrix-icon-button" title="Move up" aria-label="Move up"
                                        disabled=${row == 0} onclick=${(_) -> model.matrix.move(concept, -1)}>
                                    <Icon kind="chevron-up" size=14 />
                                </button>
                                <button type="button" class="matrix-icon-button" title="Move down" aria-label="Move down"
                                        disabled=${row == last} onclick=${(_) -> model.matrix.move(concept, 1)}>
                                    <Icon kind="chevron-down" size=14 />
                                </button>
                            </div>
                        </td>
                        <th class=${rowheadClass(row, concept)} title=${concept.name}>
                            <input class=${model.matrix.selectedRow == concept ? "matrix-name-selected" : "matrix-name"}
                                   style=${{ width: nameWidth }} data-concept=${row}
                                   value=${concept.name} aria-label="Concept name"
                                   oninput=${(e) -> rename(concept, e)}
                                   onkeydown=${(e) -> leaveOnEnter(e)}
                                   onblur=${(_) -> removeIfEmpty(concept)} />
                        </th>
                        <foreach ${concepts} ${(col:Int, other:Concept) -> '<>
                            <td class=${cellClass(row, col, selectedRow, selectedCol)} style=${cellStyle(concept, other)}
                                onclick=${(_) -> if (row != col) toggle(concept, other)}></td>
                        '} />
                    </tr>
                '} />
                <tr>
                    <td class="matrix-gutter"></td>
                    <td class="matrix-add">
                        <button type="button" class="matrix-icon-button" title="Add concept" aria-label="Add concept"
                                onclick=${(_) -> addConcept()}>
                            <Icon kind="plus" size=14 />
                        </button>
                    </td>
                </tr>
            </table>
        ';

    }

    /** Whole literal class strings per case, because Tailwind reads source
        text. The diagonal is a concept against itself: hatched and inert.

        The path from each header to the selected cell is lightly highlighted:
        on its row the cells left of it, on its column the cells above it,
        nothing past the crossing. */
    function cellClass(row:Int, col:Int, selectedRow:Int, selectedCol:Int):String {

        final selected = row == selectedRow && col == selectedCol;
        final cross = (row == selectedRow && col < selectedCol) || (col == selectedCol && row < selectedRow);

        if (row == col) {
            if (cross) return row == 0 ? "matrix-self matrix-cross border-t" : "matrix-self matrix-cross";
            return row == 0 ? "matrix-self border-t" : "matrix-self";
        }
        if (selected) return row == 0 ? "matrix-cell matrix-selected border-t" : "matrix-cell matrix-selected";
        if (cross) return row == 0 ? "matrix-cell matrix-cross border-t" : "matrix-cell matrix-cross";
        return row == 0 ? "matrix-cell border-t" : "matrix-cell";

    }

    /** The row header, highlighted while its row holds the selected cell. */
    function rowheadClass(row:Int, concept:Concept):String {

        if (model.matrix.selectedRow == concept) {
            return row == 0 ? "matrix-rowhead-selected border-t" : "matrix-rowhead-selected";
        }
        return row == 0 ? "matrix-rowhead border-t" : "matrix-rowhead";

    }

    /** Clicking the selected cell again closes it. */
    function toggle(rowConcept:Concept, colConcept:Concept):Void {

        final matrix = model.matrix;
        if (matrix.selectedRow == rowConcept && matrix.selectedCol == colConcept) {
            matrix.clearSelection();
        }
        else {
            matrix.select(rowConcept, colConcept);
        }

    }

    /** A cell shows its notes' colours stacked in bands, and stays plain when it
        has no note.

        Plain is an explicit empty value, not a missing key: wisdom removes a
        missing style key with a field delete, which leaves the old value on
        the element. */
    function cellStyle(rowConcept:Concept, colConcept:Concept):Dynamic {

        final intersection = model.matrix.intersection(rowConcept, colConcept);
        final background = intersection != null ? intersection.cellBackground : null;
        return { backgroundImage: background != null ? background : '' };

    }

    function rename(concept:Concept, e:Event):Void {

        final input:InputElement = cast e.target;
        concept.name = input.value;

    }

    function leaveOnEnter(e:Event):Void {

        final key = (cast e:KeyboardEvent).key;
        if (key == 'Enter' || key == 'Escape') {
            final input:InputElement = cast e.target;
            input.blur();
        }

    }

    /** Emptying a name deletes the concept, once the field is left: doing it
        on every keystroke would delete it while its name is being retyped.
        The last concept cannot be deleted, so it gets its default name back. */
    function removeIfEmpty(concept:Concept):Void {

        if (StringTools.trim(concept.name) != '') return;

        final matrix = model.matrix;
        if (matrix.concepts.length > 1) {
            matrix.remove(concept);
        }
        else {
            concept.name = matrix.defaultName();
        }

    }

    function addConcept():Void {

        final matrix = model.matrix;
        matrix.add(matrix.defaultName());
        final index = matrix.concepts.length - 1;

        // wisdom has no hook for "after this element is rendered", so wait a
        // frame for the new row to exist, then focus its field with the default
        // name selected: typing replaces it.
        window.requestAnimationFrame(_ -> {
            final input:InputElement = cast document.querySelector('input[data-concept="' + index + '"]');
            if (input != null) {
                input.focus();
                input.select();
            }
        });

    }

}
