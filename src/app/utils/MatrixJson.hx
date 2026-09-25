package app.utils;

import app.NoteColors;
import app.model.Concept;
import app.model.Intersection;
import app.model.MatrixData;
import app.model.Note;
import haxe.Json;

/**
 * The matrix file format: plain JSON, independent of class names so it
 * survives refactors, and readable enough to diff or edit by hand.
 *
 * ```json
 * {
 *   "format": "<APP_SLUG>",
 *   "version": 1,
 *   "concepts": [ { "name": "Miroir", "description": null } ],
 *   "intersections": [
 *     { "row": 1, "col": 0, "notes": [ { "color": "#ef4444", "text": "RAS" } ] }
 *   ]
 * }
 * ```
 *
 * `row` and `col` are indexes into `concepts`. Lists keep their display order.
 *
 * `format` is APP_SLUG from project.config.sh: renaming the project makes
 * files saved under the previous name unreadable.
 */
class MatrixJson {

    static final FORMAT = App.SLUG;

    static final VERSION = 1;

    public static function write(matrix:MatrixData):String {

        final concepts = matrix.concepts;
        final indexes = new Map<Concept, Int>();
        for (i in 0...concepts.length) indexes.set(concepts[i], i);

        final data = {
            format: FORMAT,
            version: VERSION,
            concepts: [for (concept in concepts) { name: concept.name, description: concept.description }],
            intersections: [for (intersection in matrix.intersections) {
                row: indexes.get(intersection.row),
                col: indexes.get(intersection.col),
                notes: [for (note in intersection.notes) { color: note.color, text: note.text }]
            }]
        };
        return Json.stringify(data, null, '  ');

    }

    /**
     * A new matrix built from `json`. Throws a message fit for the user when
     * the file is not a matrix this version can read.
     *
     * Every list is assigned once, fully built, rather than grown item by
     * item, so loading a big file does not rebuild derived values per item.
     */
    public static function read(json:String):MatrixData {

        final data:Dynamic = try Json.parse(json) catch (_:Dynamic) throw "This file is not valid JSON.";

        if (data == null || data.format != FORMAT) throw "This file is not a Concept Matrix file.";
        if (!(data.version is Int) || data.version > VERSION) {
            throw 'This file was made by a newer version of Concept Matrix.';
        }

        final matrix = new MatrixData();

        final concepts:Array<Concept> = [];
        for (item in list(data.concepts, 'concepts')) {
            if (!(item.name is String)) throw 'A concept has no valid name.';
            final description:String = item.description is String ? item.description : null;
            concepts.push(new Concept(matrix, item.name, description));
        }
        // The matrix always keeps at least one concept.
        if (concepts.length == 0) concepts.push(new Concept(matrix, matrix.defaultName()));
        matrix.concepts = concepts;

        final intersections:Array<Intersection> = [];
        for (item in list(data.intersections, 'intersections')) {
            final row = index(item.row, concepts.length);
            final col = index(item.col, concepts.length);
            if (row == col) throw 'An intersection links a concept to itself.';

            final intersection = new Intersection(matrix, concepts[row], concepts[col]);
            final notes:Array<Note> = [];
            for (note in list(item.notes, 'notes')) {
                final color:String = NoteColors.PALETTE.indexOf(note.color) != -1 ? note.color : NoteColors.DEFAULT;
                final text:String = note.text is String ? note.text : '';
                notes.push(new Note(intersection, color, text));
            }
            // An intersection only exists while it holds notes.
            if (notes.length == 0) continue;
            intersection.notes = notes;
            intersections.push(intersection);
        }
        matrix.intersections = intersections;

        return matrix;

    }

    static function list(value:Dynamic, name:String):Array<Dynamic> {

        if (value == null) return [];
        if (!(value is Array)) throw 'The "$name" list is invalid.';
        return value;

    }

    static function index(value:Dynamic, count:Int):Int {

        if (!(value is Int) || value < 0 || value >= count) throw 'An intersection refers to a concept that does not exist.';
        return value;

    }

}
