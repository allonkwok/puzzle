package com.pop136.puzzle.event {
import flash.events.Event;

public class OperationEvent extends Event {

    public static const SAVE_OPERATION:String = 'saveOperation';
    public static const UNDO:String = 'undo';
    public static const REDO:String = 'redo';
    public static const APPLY:String = 'apply';


    /**事件数据*/
    public var data:Object = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function OperationEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new OperationEvent(type, data, bubbles, cancelable);
    }
}
}
