package com.pop136.puzzle.util {
import flash.utils.ByteArray;

public class ArrayUtil {

    public static function clone(source:Object):*
    {
        var myBA:ByteArray = new ByteArray();
        myBA.writeObject(source);
        myBA.position = 0;
        return(myBA.readObject());
    }

}
}
