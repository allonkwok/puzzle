package com.pop136.puzzle.event {
import flash.events.Event;

public class TopBarEvent extends Event {

    public static const SELECT:String = 'select';
    public static const SAVE:String = 'save';
    public static const SUBMIT:String = 'submit';
    public static const CONFIRM:String = 'layoutDeleteConfirm';
    public static const AFTER_SAVE_OPERATION = 'afterSaveOperation';
    public static const AFTER_UNDO = 'AFTER_UNDO';
    public static const AFTER_REDO = 'AFTER_REDO';

    /**事件数据*/
    public var data:Object = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function TopBarEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new TopBarEvent(type, data, bubbles, cancelable);
    }
}
}
