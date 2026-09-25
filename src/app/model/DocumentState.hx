package app.model;

import kit.model.BaseModel;
import kit.platform.FileRef;
import tracker.Model;

/**
 * The file the matrix belongs to, and whether it has changed since it was
 * last saved or opened.
 *
 * Saved with the rest of the model, so a reload keeps the file to save to and
 * the unsaved state.
 */
class DocumentState extends BaseModel {

    /** Null while the matrix has never been saved. */
    @serialize public var fileName:String = null;

    /** Set on the desktop only: what lets Save overwrite in place. */
    @serialize public var filePath:String = null;

    @serialize public var unsaved:Bool = false;

    /** The models currently watched for changes. Not saved. */
    var watched:Array<Model> = [];

    var watchedSet:Map<Model, Bool> = new Map();

    var matrix:MatrixData = null;

    public function new() {
        super();
    }

    /** The current file, or null when there is none yet. */
    public function ref():FileRef {

        return fileName != null ? new FileRef(fileName, filePath) : null;

    }

    public function setFile(ref:FileRef):Void {

        fileName = ref != null ? ref.name : null;
        filePath = ref != null ? ref.path : null;

    }

    /**
     * Watches every model of `matrix` and raises `unsaved` on the first change
     * to any saved field: a name, a text, a colour, a list order.
     *
     * Uses tracker's observedDirty event, the one the autosave relies on. A
     * model emits it once, then not again until the autosave syncs it, so
     * typing costs at most one call per model per sync, with no export and no
     * comparison. The flip side: models just created, from a file just
     * opened, emit nothing until their first sync, about a second later.
     *
     * Selection and picker state are not saved fields, so they are ignored.
     */
    public function watch(matrix:MatrixData):Void {

        for (model in watched) model.offObservedDirty(modelChanged);
        watched = [];
        watchedSet = new Map();
        this.matrix = matrix;
        subscribe();

    }

    /** Subscribes to every model of the matrix not already watched. */
    function subscribe():Void {

        add(matrix);
        for (concept in matrix.concepts) add(concept);
        for (intersection in matrix.intersections) {
            add(intersection);
            for (note in intersection.notes) add(note);
        }

    }

    function add(model:Model):Void {

        if (watchedSet.exists(model)) return;
        watchedSet.set(model, true);
        watched.push(model);
        model.onObservedDirty(this, modelChanged);

    }

    function modelChanged(model:Model, fromSerializedField:Bool):Void {

        if (!fromSerializedField) return;
        unsaved = true;

        // A list was reassigned: pick up the concepts, intersections and notes
        // it may have gained.
        if (model is MatrixData || model is Intersection) subscribe();

    }

}
