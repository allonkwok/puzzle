package com.pop136.puzzle.ui {
import com.pop136.puzzle.event.LayerListEvent;
import com.pop136.puzzle.event.Messager;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;

import ui.LayerItemMc;

public class LayerItem extends Sprite {

    public var data;
    public var mc:LayerItemMc;
    private var loader:Loader;
    private var messager:Messager;

    public var photoWidth:int;
    public var photoHeight:int;

    public function LayerItem(data) {
        super();
        this.data = data;

        mc = new LayerItemMc();
        mc.mouseEnabled = mc.container.mouseEnabled = false;
        addChild(mc);

        loader = new Loader();
        loader.load(new URLRequest(data.big));
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event) {
            var bmp:Bitmap = e.target.content as Bitmap;
            photoWidth = bmp.width;
            photoHeight = bmp.height;
            bmp.smoothing = true;
            if(bmp.width>bmp.height){
                var rate = 220/bmp.width;
                bmp.width = 220;
                bmp.height = bmp.height*rate;
            }else{
                var rate = 110/bmp.height;
                bmp.width = bmp.width*rate;
                bmp.height = 110;
            }

            if(bmp.width>220){
                var rate = 220/bmp.width;
                bmp.width = 220;
                bmp.height = bmp.height*rate;
            }else if(bmp.height>110){
                var rate = 110/bmp.height;
                bmp.width = bmp.width*rate;
                bmp.height = 110;
            }

            bmp.x = (220-bmp.width)/2;
            bmp.y = (110-bmp.height)/2;
            mc.container.addChild(bmp);
        });

        messager = Messager.getInstance();

        addEventListener(MouseEvent.CLICK, onClick);
    }

    private function onClick(e:MouseEvent):void{
        if(e.target.name=='btn'){
            this.parent.removeChild(this);
            messager.dispatchEvent(new LayerListEvent(LayerListEvent.DELETE));
        }
    }

    public function dispose(){
        var bmp:Bitmap = mc.container.removeChildAt(0) as Bitmap;
        bmp.bitmapData.dispose();
        bmp = null;
        mc = null;
        loader = null;
        data = null;
    }

}
}
