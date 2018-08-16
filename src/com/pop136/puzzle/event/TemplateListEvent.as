package com.pop136.puzzle.event {
import flash.events.Event;

public class TemplateListEvent extends Event {

    public static const CREATE_COMPLETE:String = 'createComplete';
    public static const CHANGE:String = 'change';
    public static const CONFIRM:String = 'templateConfirm';

    /**事件数据*/
    public var data:Object = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function TemplateListEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new TemplateListEvent(type, data, bubbles, cancelable);
    }
}
}
