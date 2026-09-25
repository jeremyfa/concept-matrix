package app.utils;

import js.html.CanvasRenderingContext2D;

/**
 * Geometry helpers for the matrix's slanted column headers.
 *
 * Column labels are absolutely positioned and rotated, so they cannot size
 * their header the way ordinary content would: the caller measures the text it
 * wants to fit and derives the header dimensions from that width. Past
 * `MAX_TEXT`, labels are cut with an ellipsis rather than growing the header
 * further.
 *
 * These values go through inline styles rather than a CSS variable because
 * wisdom sets style properties by field, which does not reach custom
 * properties.
 */
class MatrixLayoutUtils {

    /** The slant of the column headers, from vertical. Matches `-skew-x-30`
        in app.css; the label rotates by its complement, `-rotate-60`. */
    static final ANGLE = 30 * Math.PI / 180;

    /** The longest label, in pixels, before it gets an ellipsis. Applies to
        row headers too, so both axes cut at the same length. */
    public static final MAX_TEXT = 180;

    /** Space before the label along the slant (its `pl-3.5`), and after it. */
    static final PAD_START = 14;
    static final PAD_END = 14;

    /** Matches `text-[12px] font-medium` on matrix-label and matrix-rowhead. */
    static final FONT_WEIGHT = '500';
    static final FONT_SIZE = '12px';

    static var context:CanvasRenderingContext2D = null;

    /** Width of `text` in the label font. */
    public static function measure(text:String):Float {

        if (context == null) {
            context = js.Browser.document.createCanvasElement().getContext2d();
        }
        final family = js.Browser.window.getComputedStyle(js.Browser.document.body).fontFamily;
        context.font = '$FONT_WEIGHT $FONT_SIZE $family';
        return context.measureText(text).width;

    }

    /** Header height fitting a label `textWidth` wide, capped at `MAX_TEXT`. */
    public static function headHeight(textWidth:Float):Int {

        final text = Math.min(Math.ceil(textWidth), MAX_TEXT);
        return Math.ceil((text + PAD_START + PAD_END) * Math.cos(ANGLE));

    }

    /** How far the last slant overhangs the grid to the right. */
    public static function overhang(headHeight:Int):Int {

        return Math.ceil(headHeight * Math.tan(ANGLE));

    }

    /** Maximum width of a column label box, padding included. */
    public static function labelMaxWidth(headHeight:Int):Int {

        return Math.floor(headHeight / Math.cos(ANGLE)) - PAD_END;

    }

}
