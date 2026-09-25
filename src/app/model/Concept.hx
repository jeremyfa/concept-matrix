package app.model;

import kit.model.BaseModel;

class Concept extends BaseModel {

    @serialize public var matrix:MatrixData;

    @serialize public var name:String;

    @serialize public var description:String = null;

    public function new(matrix:MatrixData, name:String, ?description:String) {
        super();
        this.matrix = matrix;
        this.name = name;
        if (description != null) {
            this.description = description;
        }
    }

}
