package app;

/**
 * The colours a note can take, and how they are shown.
 *
 * A note stores a plain hex colour. It is never painted as is: it is mixed
 * into the theme's surface colour, so the same colour reads as a soft tint in
 * both the light and the dark theme, and text on it keeps the theme's own
 * colour.
 */
class NoteColors {

    /** The colour of a new note. */
    public static final DEFAULT = '#6b7280';

    /** Mid-saturation colours that stay distinct once mixed into a surface,
        grey (the default) first. */
    public static final PALETTE = [
        '#6b7280', // grey
        '#22c55e', // green
        '#ef4444', // red
        '#f59e0b', // amber
        '#3b82f6', // blue
        '#8b5cf6', // violet
        '#ec4899', // pink
        '#06b6d4'  // cyan
    ];

    /**
     * How much of its colour a note shows, and its band in a grid cell. Both
     * depend on the theme, so they are the CSS variables --note-card-mix and
     * --note-cell-mix, set per theme in app.css. The note carries text, so it
     * stays a tint; the band carries none and can show the colour itself.
     */
    public static function noteTint(color:String):String {

        return tint(color, 'var(--note-card-mix)');

    }

    public static function cellTint(color:String):String {

        return tint(color, 'var(--note-cell-mix)');

    }

    /** `color` mixed at `amount` into the surface, or the neutral surface
        when there is no colour.

        Mixed in oklab: srgb dulls a colour mixed into a dark surface and turns
        orange into brown, and oklch interpolates hues, so red mixed into the
        slightly blue dark surface swings through magenta. oklab keeps the
        colour's own hue and most of its vividness. */
    static function tint(color:String, amount:String):String {

        if (color == null) return 'var(--t-surface-2)';
        return 'color-mix(in oklab, $color $amount, var(--t-surface))';

    }

}
