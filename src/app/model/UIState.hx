package app.model;

import kit.model.BaseModel;

/**
 * How the interface is laid out, as the user left it.
 *
 * Kept apart from the matrix, which New and Open replace: the layout belongs
 * to the app, not to the document.
 */
class UIState extends BaseModel {

    /** Width of the notes panel, in pixels, set by dragging its left edge. */
    @serialize public var notePanelWidth:Float = 300;

    /** While the panel edge is being dragged. Not saved. */
    @observe public var resizingNotePanel:Bool = false;

    public function new() {
        super();
    }

}
