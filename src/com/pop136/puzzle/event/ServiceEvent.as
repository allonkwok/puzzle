package com.pop136.puzzle.event {
import flash.events.Event;

public class ServiceEvent extends Event {

    public static const GET_TEMPLATE_COMPLETE:String = 'getTemplateComplete';
    public static const GET_SOURCE_COMPLETE:String = 'getSourceComplete';
    public static const GET_LAYOUT_COMPLETE:String = 'getLayoutComplete';
    public static const SAVE_LAYOUT_IMAGE_COMPLETE:String = 'saveLayoutImageComplete';
    public static const SET_FULL_SCREEN:String = 'setFullScreen';

    /**事件数据*/
    public var data = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function ServiceEvent($type:String, $data = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new ServiceEvent(type, data, bubbles, cancelable);
    }
}
}
