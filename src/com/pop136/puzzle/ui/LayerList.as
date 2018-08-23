package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.LayerDialogEvent;
import com.pop136.puzzle.event.LayerListEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.manager.PopupManager;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.geom.Rectangle;

import ui.LayerBtn;

public class LayerList extends Sprite{

    private var layerBtn:LayerBtn;
    private var masker:Sprite;
    private var container:Sprite;
    private var scrollbar:Sprite;
    private var scrollbg:Shape;
    private var n:int;
    private var messager:Messager = Messager.getInstance();

    public function LayerList() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function setSources(arr:Array){

        for(var i:int=0,n=container.numChildren;i<n;i++){
            if(container.getChildAt(0)==layerBtn){
                layerBtn.y = 0;
            }else{
                var item = container.removeChildAt(0);
                item.dispose();
                item = null;
            }
        }
        scrollbg.visible = scrollbar.visible = false;

        for(var i:int=0;i<arr.length;i++){
            addItem(arr[i]);
        }
    }

    public function getSources():Array{
        var arr:Array = [];
        for(var i:int=0,n=container.numChildren;i<n;i++){
            var item = container.getChildAt(i);
            if(item!=layerBtn){
                arr.push(item.data);
            }
        }
        return arr;
    }

    private function onDelete(e:LayerListEvent):void{
        for(var i:int=0; i<container.numChildren; i++){
            var item = container.getChildAt(i);
            item.y = i * (item.height+10);
        }
    }

    private function onClick(e:MouseEvent):void{
        if(e.target==layerBtn){
            PopupManager.showLayerDialog();
        }
    }

    private function onLayerDialogSave(e:LayerDialogEvent):void{
        addItem(e.data);
    }

    public function addItem(data):void{
        var item:LayerItem = new LayerItem(data);
        item.x = 10;
        item.y = (container.numChildren-1) * (item.height+10);
        container.addChild(item);

        layerBtn.x = item.x;
        layerBtn.y = item.y + 10 + item.height;
        container.addChild(layerBtn);

        var h = masker.height * (masker.height/container.height);
        trace(masker.height, container.height, h);

        scrollbar.graphics.clear();
        scrollbar.graphics.beginFill(Config.GRAY_DARK);
        scrollbar.graphics.drawRoundRect(0, 0, 5, h, 5, 5);
        scrollbar.graphics.endFill();

        if(container.height>masker.height){
            scrollbg.visible = scrollbar.visible = true;
        }else{
            scrollbg.visible = scrollbar.visible = false;
        }
    }

    private function onAddedToStage(e:Event):void{
        container = new Sprite();
        addChild(container);

        layerBtn = new LayerBtn();
        layerBtn.name = "layerBtn";
        layerBtn.x = 10;
        container.addChild(layerBtn);

        scrollbg = new Shape();
        scrollbg.x = 232.5;
        addChild(scrollbg);

        scrollbar = new Sprite();
        addChild(scrollbar);
        scrollbar.x = 232.5;
        scrollbar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        var p:Point = localToGlobal(new Point(container.x, container.y));
        trace('LayerList.onAddedToStage.p:', p);
        masker = new Sprite();
        masker.name = "masker";
        masker.graphics.beginFill(0xcccccc);
        masker.graphics.drawRect(0, 0, 240, stage.stageHeight-p.y-10);
        masker.graphics.endFill();
        addChild(masker);

        scrollbg.graphics.beginFill(Config.GRAY_LIGHT);
        scrollbg.graphics.drawRoundRect(0, 0, 5, masker.height, 5, 5);
        scrollbg.graphics.endFill();

        container.mask = masker;

        if(!ExternalInterface.available){
            var arr:Array = [
                'asset/image/layer/1.jpg',
                'asset/image/layer/2.jpg',
                'asset/image/layer/3.jpg',
                'asset/image/layer/4.jpg',
                'asset/image/layer/5.png',
                'asset/image/layer/6.png',
                'asset/image/layer/7.png',
                'asset/image/layer/8.jpg',
                'asset/image/layer/9.jpg'
            ];
            for(var i:int=0;i<arr.length;i++){
                var data = {id:i, small:arr[i], big:arr[i], brand:'brand'+i, description:'description'+i, link:'link'+i, linkType:i%2+1};
                addItem(data);
            }
        }

        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(MouseEvent.CLICK, onClick);
        messager.addEventListener(LayerDialogEvent.SAVE, onLayerDialogSave);
        messager.addEventListener(LayerListEvent.DELETE, onDelete);
        stage.addEventListener(Event.RESIZE, onResize);
        trace('LayerList.container.Height:', container.height);
        trace('LayerList.scrollBg.Height:', scrollbg.height);
        trace('LayerList.scrollBar.Height:', scrollbar.height);
        trace('LayerList.masker.Height:', masker.height);
        trace('LayerList.Height:', height);
        onResize(null);
    }

    private function onMouseDown(e:MouseEvent):void{
        scrollbar.startDrag(false, new Rectangle(232.5, 0, 0, masker.height-scrollbar.height));
        scrollbar.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        scrollbar.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    private function onMouseMove(e:MouseEvent):void{
        var total:int = container.height - masker.height;
        var percent:Number = scrollbar.y/(masker.height-scrollbar.height);
        container.y = -percent*total;
    }

    private function onMouseUp(e:MouseEvent):void{
        scrollbar.stopDrag();
        scrollbar.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        scrollbar.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    private function onMouseWheel(e:MouseEvent):void{
        if(container.height>masker.height){
            var total:int = container.height - masker.height;
            if(e.delta>0){
                scrollbar.y -= 10;
            }else{
                scrollbar.y += 10;
            }
            if(scrollbar.y<0) scrollbar.y = 0;
            if(scrollbar.y>masker.height-scrollbar.height) scrollbar.y = masker.height-scrollbar.height;
            var percent:Number = scrollbar.y/(masker.height-scrollbar.height);
            container.y = -percent*total;
        }
    }

    public function onResize(e:Event):void{

        container.x = container.y = scrollbar.y = 0;

        var p:Point = localToGlobal(new Point(container.x, container.y));
        masker.graphics.clear();
        masker.graphics.beginFill(0xcccccc);
        masker.graphics.drawRect(0, 0, 240, stage.stageHeight-p.y-10);
        masker.graphics.endFill();

        var h = masker.height * (masker.height/container.height);
        scrollbar.graphics.clear();
        scrollbar.graphics.beginFill(Config.GRAY_DARK);
        scrollbar.graphics.drawRoundRect(0, 0, 5, h, 5, 5);
        scrollbar.graphics.endFill();

        scrollbg.graphics.clear();
        scrollbg.graphics.beginFill(Config.GRAY_LIGHT);
        scrollbg.graphics.drawRoundRect(0, 0, 5, masker.height, 5, 5);
        scrollbg.graphics.endFill();

        if(container.height<=masker.height){
            scrollbar.visible = scrollbg.visible = false;
        }else {
            scrollbar.visible = scrollbg.visible = true;
        }

    }
}
}
