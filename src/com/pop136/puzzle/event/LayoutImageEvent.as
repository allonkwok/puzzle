package com.pop136.puzzle.event {
import flash.events.Event;

public class LayoutImageEvent extends Event {

    public static const DRAW_COMPLETE:String = "drawComplete";

    /**事件数据*/
    public var data:Object = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function LayoutImageEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new LayoutImageEvent(type, data, bubbles, cancelable);
    }
}
}
