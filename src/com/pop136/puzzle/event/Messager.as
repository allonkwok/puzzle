package com.pop136.puzzle.event
{
import flash.events.EventDispatcher;

/**
 * 信使类
 * */
public class Messager extends EventDispatcher{

    private static var _instance:Messager = new Messager;

    /**
     * 构造函数
     * */
    public function Messager()
    {
        if(_instance){
            throw new Error("Messager是单例，请使用Messager.getInstance()方法获取实例！");
        }
    }

    /**
     * 获取实例
     * @return	com.pop136.puzzle.event.Messager
     * */
    public static function getInstance():Messager{
        return _instance;
    }

}
}