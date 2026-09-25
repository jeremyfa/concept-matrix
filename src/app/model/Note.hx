package app.model;

import app.NoteColors;
import kit.model.BaseModel;

class Note extends BaseModel {

    @serialize public var intersection:Intersection;

    /** One of NoteColors.PALETTE. Notes saved before colours existed load
        with the default. */
    @serialize public var color:String = NoteColors.DEFAULT;

    @serialize public var text:String;

    public function new(intersection:Intersection, color:String, text:String) {
        super();
        this.intersection = intersection;
        this.color = color;
        this.text = text;
    }

}
