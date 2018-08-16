package com.pop136.puzzle.event {
import flash.events.Event;

public class CanvasEvent extends Event {

    public static const SCALE:String = 'scale';
    public static const GRID_SCALE:String = 'gridScale';
    public static const GRID_SELECTED:String = 'gridSelected';
    public static const LAYER_SCALE:String = 'layerScale';
    public static const LAYER_SELECTED:String = 'layerSelected';
    public static const GRID_MERGE:String = 'gridMerge';

    /**事件数据*/
    public var data:Object = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function CanvasEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new CanvasEvent(type, data, bubbles, cancelable);
    }
}
}
