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
        final hoveredRow = concepts.indexOf(model.matrix.hoveredRow);
        final hoveredCol = concepts.indexOf(model.matrix.hoveredCol);

        return '<>
            <table class="matrix-table group/matrix" style=${{ marginRight: overhang }}>
                <tr>
                    <td class="matrix-gutter"></td>
                    <td class="p-0"></td>
                    <foreach ${concepts} ${(_:Int, concept:Concept) -> '<>
                        <th class="matrix-head" style=${{ height: headHeight }}>
                            <div class=${isSelectedCol(concept) ? "matrix-slant-selected" : "matrix-slant"}></div>
                            <div class=${isSelectedCol(concept) ? "matrix-label-selected" : "matrix-label"}
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
                            <input class=${isSelectedRow(concept) ? "matrix-name-selected" : "matrix-name"}
                                   style=${{ width: nameWidth }} data-concept=${row}
                                   value=${concept.name} aria-label="Concept name"
                                   onclick=${(e) -> selectDefaultName(concept, e)}
                                   oninput=${(e) -> rename(concept, e)}
                                   onkeydown=${(e) -> handleKey(concept, e)}
                                   onblur=${(_) -> removeIfEmpty(concept)} />
                        </th>
                        <foreach ${concepts} ${(col:Int, other:Concept) -> '<>
                            <td class=${cellClass(row, col, selectedRow, selectedCol, hoveredRow, hoveredCol)}
                                style=${cellStyle(concept, other)}
                                onmouseenter=${(_) -> hover(concept, other)}
                                onmouseleave=${(_) -> unhover(concept, other)}
                                onclick=${(_) -> toggle(concept, other)}></td>
                        '} />
                    </tr>
                '} />
                <tr>
                    <td class="matrix-gutter"></td>
                    <td class="matrix-add">
                        <button type="button" class="matrix-icon-button" title="Add concept" aria-label="Add concept"
                                onclick=${(e) -> addConcept(e)}>
                            <Icon kind="plus" size=14 />
                        </button>
                    </td>
                </tr>
            </table>
        ';

    }

    /** Whole literal class strings per case, because Tailwind reads source
        text. The diagonal is a concept against itself: hatched, and selectable
        like the other cells.

        While a cell is selected, every other cell is dimmed, so it stands out.
        In symmetric mode the other cell of the selected pair stays lit and
        outlined too, since it shows the same notes, and the other cell of the
        hovered one lights up like it. The diagonal is its own pair. */
    function cellClass(row:Int, col:Int, selectedRow:Int, selectedCol:Int, hoveredRow:Int, hoveredCol:Int):String {

        final selected = (row == selectedRow && col == selectedCol)
            || (model.matrix.symmetric && row == selectedCol && col == selectedRow);
        final mirrorHovered = row == hoveredCol && col == hoveredRow;
        final dim = selectedRow != -1 && !selected;

        if (row == col) {
            if (selected) return row == 0 ? "matrix-self matrix-selected border-t" : "matrix-self matrix-selected";
            if (dim) return row == 0 ? "matrix-self matrix-dim border-t" : "matrix-self matrix-dim";
            return row == 0 ? "matrix-self border-t" : "matrix-self";
        }
        if (selected && mirrorHovered) {
            return row == 0 ? "matrix-cell matrix-selected matrix-hovered border-t" : "matrix-cell matrix-selected matrix-hovered";
        }
        if (selected) return row == 0 ? "matrix-cell matrix-selected border-t" : "matrix-cell matrix-selected";
        // Lit rather than dimmed, like the hovered cell itself.
        if (mirrorHovered) return row == 0 ? "matrix-cell matrix-hovered border-t" : "matrix-cell matrix-hovered";
        if (dim) return row == 0 ? "matrix-cell matrix-dim border-t" : "matrix-cell matrix-dim";
        return row == 0 ? "matrix-cell border-t" : "matrix-cell";

    }

    /** Tracked in symmetric mode only: elsewhere CSS hover is enough, and
        nothing re-renders as the mouse moves. */
    function hover(rowConcept:Concept, colConcept:Concept):Void {

        final matrix = model.matrix;
        if (!matrix.symmetric || rowConcept == colConcept) return;
        matrix.hoveredRow = rowConcept;
        matrix.hoveredCol = colConcept;

    }

    function unhover(rowConcept:Concept, colConcept:Concept):Void {

        final matrix = model.matrix;
        if (matrix.hoveredRow != rowConcept || matrix.hoveredCol != colConcept) return;
        matrix.hoveredRow = null;
        matrix.hoveredCol = null;

    }

    /** Whether the header of `concept` is highlighted as a row of the
        selection. In symmetric mode a pair has no direction, so the two
        concepts of the selected pair are highlighted both as rows and as
        columns. */
    function isSelectedRow(concept:Concept):Bool {

        final matrix = model.matrix;
        return matrix.selectedRow == concept || (matrix.symmetric && matrix.selectedCol == concept);

    }

    function isSelectedCol(concept:Concept):Bool {

        final matrix = model.matrix;
        return matrix.selectedCol == concept || (matrix.symmetric && matrix.selectedRow == concept);

    }

    /** The row header, highlighted while its row holds the selected cell. */
    function rowheadClass(row:Int, concept:Concept):String {

        if (isSelectedRow(concept)) {
            return row == 0 ? "matrix-rowhead-selected border-t" : "matrix-rowhead-selected";
        }
        return row == 0 ? "matrix-rowhead border-t" : "matrix-rowhead";

    }

    /** Clicking the selected cell again closes it, and in symmetric mode so
        does clicking the other cell of its pair, which shows as selected. */
    function toggle(rowConcept:Concept, colConcept:Concept):Void {

        final matrix = model.matrix;
        final same = matrix.selectedRow == rowConcept && matrix.selectedCol == colConcept;
        final mirror = matrix.symmetric && matrix.selectedRow == colConcept && matrix.selectedCol == rowConcept;
        if (same || mirror) {
            matrix.clearSelection();
        }
        else {
            matrix.select(rowConcept, colConcept);
        }

    }

    /** A cell shows its notes' colours stacked in bands, and stays plain when it
        has no note. In symmetric mode both cells of a pair show the same. On the diagonal the hatching stays on top of the bands:
        an inline background replaces the one of matrix-self, so it is
        repeated here.

        Plain is an explicit empty value, not a missing key: wisdom removes a
        missing style key with a field delete, which leaves the old value on
        the element. */
    function cellStyle(rowConcept:Concept, colConcept:Concept):Dynamic {

        final intersection = model.matrix.cell(rowConcept, colConcept);
        final background = intersection != null ? intersection.cellBackground : null;
        if (background == null) return { backgroundImage: '' };
        return { backgroundImage: rowConcept == colConcept ? SELF_HATCH + ', ' + background : background };

    }

    /** The stripes of matrix-self, in app.css. */
    static final SELF_HATCH = 'repeating-linear-gradient(-45deg, transparent 0 4px, var(--t-border) 4px 5px)';

    function rename(concept:Concept, e:Event):Void {

        final input:InputElement = cast e.target;
        concept.name = input.value;

    }

    /** A name still at its default is a placeholder: clicking it selects it
        whole, so typing replaces it. On click rather than focus, because the
        mouseup that follows a focus would place the caret and undo it. */
    function selectDefaultName(concept:Concept, e:Event):Void {

        if (concept.name != model.matrix.defaultName()) return;
        final input:InputElement = cast e.target;
        input.select();

    }

    /** Enter or Escape leaves the name, Shift+Backspace deletes the concept.
        The last concept cannot be deleted, so it gets its default name back,
        selected so typing replaces it. */
    function handleKey(concept:Concept, e:Event):Void {

        final key:KeyboardEvent = cast e;
        if (key.isComposing) return;

        final input:InputElement = cast e.target;
        if (key.key == 'Enter' || key.key == 'Escape') {
            input.blur();
        }
        else if (key.key == 'Backspace' && key.shiftKey) {
            e.preventDefault();
            final matrix = model.matrix;
            if (matrix.concepts.length > 1) {
                matrix.remove(concept);
            }
            else {
                concept.name = matrix.defaultName();
                input.value = concept.name;
                input.select();
            }
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

    function addConcept(e:Event):Void {

        // The new row takes the place of the + row, and wisdom reuses its
        // cell for the new diagonal one while this click is still bubbling:
        // left to bubble, it would reach that cell and select it.
        e.stopPropagation();

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
