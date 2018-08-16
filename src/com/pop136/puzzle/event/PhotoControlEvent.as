package com.pop136.puzzle.event {
import flash.events.Event;

public class PhotoControlEvent extends Event {

    public static const SLIDE:String = 'slide';
    public static const ROTATE:String = 'rotate';
    public static const HORIZONTAL:String = 'horizontal';
    public static const VERTICAL:String = 'vertical';
    public static const SELECT:String = 'select';
    public static const DRAG:String = 'drag';
    public static const DELETE:String = 'delete';
    public static const LINK:String = 'link';

    /**事件数据*/
    public var data:Object = null;

    /**构造函数
     * @param    $type    事件类型
     * @param    $data    事件数据
     * @param    $bubbles    是否冒泡
     * @param    $cancelable    是否可取消
     */
    public function PhotoControlEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false) {
        super($type, $bubbles, $cancelable);
        this.data = $data;
    }

    override public function clone():Event {
        return new PhotoControlEvent(type, data, bubbles, cancelable);
    }
}
}
