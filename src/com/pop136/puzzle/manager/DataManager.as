package com.pop136.puzzle.manager {
import flash.geom.Rectangle;

public class DataManager {

    public static var stageWidth:int;
    public static var stageHeight:int;

    public static var templates:Array = [];
    public static var templateIndex:int;
    public static var layouts:Array = [];
    public static var layoutTmpId:int;

    public static var viewRect:Rectangle;

    public static function getLayout(tmpid:int){
        trace(layouts.length);
        var obj;
        for(var i:int=0;i<layouts.length;i++){
            if(layouts[i].tmpid==tmpid){
                obj = layouts[i];
                break;
            }
        }
        return obj;
    }

    public static function removeLayout(tmpid:int){
        for(var i:int=0;i<layouts.length;i++){
            if(layouts[i].tmpid==tmpid){
                layouts.removeAt(i);
                break;
            }
        }
    }

}
}
