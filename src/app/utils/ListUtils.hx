package app.utils;

import facile.ReadOnlyArray;

class ListUtils {

    /**
     * A copy of `list` where `item` is swapped with its neighbour `delta`
     * places away (-1 or +1), or null when that would leave the list.
     *
     * Returns a copy on purpose: observed arrays are compared by identity, so
     * the caller must assign the result for the change to be seen.
     */
    public static function moved<T>(list:ReadOnlyArray<T>, item:T, delta:Int):Array<T> {

        final index = list.indexOf(item);
        final target = index + delta;
        if (index == -1 || target < 0 || target >= list.length) return null;

        final copy:Array<T> = [].concat(list);
        copy[index] = copy[target];
        copy[target] = item;
        return copy;

    }

}
