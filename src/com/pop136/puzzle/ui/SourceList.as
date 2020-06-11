package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.ServiceEvent;
import com.pop136.puzzle.manager.PopupManager;
import com.pop136.puzzle.manager.ServiceManager;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import ui.SourceListBtnMc;
import ui.SourcePhotoBtn;
import ui.SourcePhotoMc;

public class SourceList extends Sprite{

    private var sourcePhotoBtn:SourcePhotoBtn;
    private var btn:SourceListBtnMc;

    private var container:Sprite;
    private var masker:Sprite;
    private var hScrollbar:Sprite;
    private var hScrollbg:Sprite;
    private var vScrollbar:Sprite;
    private var vScrollbg:Sprite;

    private var isScrollBar:Boolean;

    private var messager:Messager = Messager.getInstance();

    public var data:Array = [];


    private static const NORMAL:String = 'normal';
    private static const EXPAND:String = 'expand';
    private static const MINIMAL:String = 'minimal';

    private var status:String = NORMAL;

    public function SourceList() {

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

    }

    private function onAddedToStage(e:Event):void{

        btn = new SourceListBtnMc();
        btn.expandMc.buttonMode = btn.minimalMc.buttonMode = true;
        btn.expandMc.mouseChildren = btn.minimalMc.mouseChildren = false;
        btn.minimalMc.status_mc.gotoAndStop('expand');
        addChild(btn);

        masker = new Sprite();
        masker.y = btn.height;
        masker.name = "masker";
        addChild(masker);
        drawRect(masker, Config.GRAY, stage.stageWidth-Config.ACCORDION_WIDTH, 240, true);

        container = new Sprite();
        container.y = btn.height;
        addChild(container);
        drawRect(container, Config.WHITE, stage.stageWidth-Config.ACCORDION_WIDTH, 240, true);

        hScrollbg = new Sprite();
        hScrollbg.x = Config.GAP*2;
        hScrollbg.y = 265;
        addChild(hScrollbg);
        drawRoundRect(hScrollbg, Config.GRAY_LIGHT, masker.width-Config.GAP*4, 5);

        hScrollbar = new Sprite();
        hScrollbar.x = Config.GAP*2;
        hScrollbar.y = 265;
        addChild(hScrollbar);

        vScrollbg = new Sprite();
        vScrollbg.x = stage.stageWidth-Config.ACCORDION_WIDTH-Config.GAP*2;
        vScrollbg.y = btn.height + Config.GAP*2;
        vScrollbg.visible = false;
        addChild(vScrollbg);

        vScrollbar = new Sprite();
        vScrollbar.x = stage.stageWidth-Config.ACCORDION_WIDTH-Config.GAP*2;
        vScrollbar.y = btn.height + Config.GAP*2;
        vScrollbar.visible = false;
        addChild(vScrollbar);

        sourcePhotoBtn = new SourcePhotoBtn();
        sourcePhotoBtn.x = Config.GAP*2;
        sourcePhotoBtn.y = Config.GAP*2;
        container.addChild(sourcePhotoBtn);

        container.mask = masker;


        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.CLICK, onClick);
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
        stage.addEventListener(Event.RESIZE, onResize);

        messager.addEventListener(ServiceEvent.GET_SOURCE_COMPLETE, function (e:ServiceEvent) {
            setSourceList(e.data.toString());
        })

        if(!ExternalInterface.available){
            var json:String = "[" +
//                    "{\"id\":2017090601312168, \"small\":\"asset/image/source/2017090601312168.jpg\", \"big\":\"asset/image/source/2017090601312168.jpg\"}," +
//                    "{\"id\":2017090601315739, \"small\":\"asset/image/source/2017090601315739.jpg\", \"big\":\"asset/image/source/2017090601315739.jpg\"}," +
//                    "{\"id\":2017090601320691, \"small\":\"asset/image/source/2017090601320691.jpg\", \"big\":\"asset/image/source/2017090601320691.jpg\"}," +
//                    "{\"id\":2017090601321789, \"small\":\"asset/image/source/2017090601321789.jpg\", \"big\":\"asset/image/source/2017090601321789.jpg\"}," +
//                    "{\"id\":2017090601322519, \"small\":\"asset/image/source/2017090601322519.jpg\", \"big\":\"asset/image/source/2017090601322519.jpg\"}," +
//                    "{\"id\":2017090601323315, \"small\":\"asset/image/source/2017090601323315.jpg\", \"big\":\"asset/image/source/2017090601323315.jpg\"}," +
//                    "{\"id\":2017090601324039, \"small\":\"asset/image/source/2017090601324039.jpg\", \"big\":\"asset/image/source/2017090601324039.jpg\"}," +
//                    "{\"id\":2017090601324703, \"small\":\"asset/image/source/2017090601324703.jpg\", \"big\":\"asset/image/source/2017090601324703.jpg\"}," +
//                    "{\"id\":2017090601331756, \"small\":\"asset/image/source/2017090601331756.jpg\", \"big\":\"asset/image/source/2017090601331756.jpg\"}," +
                    "{\"id\":2017090601332723, \"brand\":\"品牌1\", \"small\":\"asset/image/source/2017090601332723.jpg\", \"big\":\"asset/image/source/2017090601332723.jpg\"}," +
                    "{\"id\":2017090601333474, \"brand\":\"品牌2\", \"small\":\"asset/image/source/2017090601333474.jpg\", \"big\":\"asset/image/source/2017090601333474.jpg\"}," +
                    "{\"id\":2017090601334336, \"brand\":\"品牌3\", \"small\":\"asset/image/source/2017090601334336.jpg\", \"big\":\"asset/image/source/2017090601334336.jpg\"}," +
                    "{\"id\":2017090601335155, \"brand\":\"品牌4\", \"small\":\"asset/image/source/2017090601335155.jpg\", \"big\":\"asset/image/source/2017090601335155.jpg\"}," +
                    "{\"id\":2017090601353158, \"brand\":\"品牌5\", \"small\":\"asset/image/source/2017090601353158.jpg\", \"big\":\"asset/image/source/2017090601353158.jpg\"}," +
                    "{\"id\":2017090601353749, \"brand\":\"品牌6\", \"small\":\"asset/image/source/2017090601353749.jpg\", \"big\":\"asset/image/source/2017090601353749.jpg\"}" +
                    "]";
            setSourceList(json);
        }
    }

    private function change(status:String){
        container.x = 0;
        container.y = btn.height;
        container.graphics.clear();
        if(status==NORMAL){

            for(var i:int=1; i<container.numChildren; i++){
                var item = container.getChildAt(i);
                item.x = Config.GAP*2 + i * (item.width + Config.GAP*2);
                item.y = Config.GAP*2;
            }
            var w:int = (container.width>masker.width) ? container.width+Config.GAP*4 : stage.stageWidth-Config.ACCORDION_WIDTH;
            drawRect(masker, Config.GRAY, stage.stageWidth-Config.ACCORDION_WIDTH, 240);
            drawRect(container, Config.WHITE, w, 240);
            drawRoundRect(hScrollbar, Config.GRAY_DARK, masker.width * (masker.width/container.width), 5);
            drawRoundRect(hScrollbg, Config.GRAY_LIGHT, masker.width-Config.GAP*4, 5);

            vScrollbg.visible = vScrollbar.visible = false;
            if(container.width>masker.width){
                hScrollbg.visible = hScrollbar.visible = true;
            }else{
                hScrollbg.visible = hScrollbar.visible = false;
            }
            this.y = stage.stageHeight - masker.height - btn.height;

        }else if(status==EXPAND) {

            var w:int = stage.stageWidth-Config.ACCORDION_WIDTH;
            var n:int = Math.floor(w/(sourcePhotoBtn.width+Config.GAP*2));

            for(var i:int=1; i<container.numChildren; i++){
                var item = container.getChildAt(i);
                item.x = Config.GAP*2 + i%n * (item.width + Config.GAP*2);
                item.y = Config.GAP*2 + Math.floor(i/n) * (item.height + Config.GAP*2);
            }
            drawRect(masker, Config.GRAY, stage.stageWidth-Config.ACCORDION_WIDTH, 470);
            drawRect(container, Config.WHITE, stage.stageWidth-Config.ACCORDION_WIDTH, container.height+Config.GAP*4);
            drawRoundRect(vScrollbg, Config.GRAY_LIGHT, 5, masker.height-Config.GAP*4);
            drawRoundRect(vScrollbar, Config.GRAY_DARK, 5, masker.height * (masker.height/container.height));

            hScrollbg.visible = hScrollbar.visible = false;
            if(container.height>masker.height){
                vScrollbg.visible = vScrollbar.visible = true;
                vScrollbg.x = vScrollbar.x = stage.stageWidth-Config.ACCORDION_WIDTH-Config.GAP*2;
            }else{
                vScrollbg.visible = vScrollbar.visible = false;
            }
            this.y = stage.stageHeight - masker.height - btn.height;

        }else if(status==MINIMAL){
            this.y = stage.stageHeight - btn.height;
        }
        this.status = status;
    }

    private function onMouseDown(e:MouseEvent):void{
        if(e.target==hScrollbar || e.target==vScrollbar){
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            isScrollBar = true;
        }
        if(e.target==hScrollbar){
            hScrollbar.startDrag(false, new Rectangle(Config.GAP*2, 265, hScrollbg.width-hScrollbar.width, 0));
        }
        if(e.target==vScrollbar){
            vScrollbar.startDrag(false, new Rectangle(stage.stageWidth-Config.ACCORDION_WIDTH-Config.GAP*2, btn.height + Config.GAP*2, 0, vScrollbg.height-vScrollbar.height));
        }
    }

    private function onMouseMove(e:MouseEvent):void{
        if(isScrollBar && status==NORMAL){
            var total:int = container.width - masker.width;
            var percent:Number = (hScrollbar.x-Config.GAP*2)/(hScrollbg.width-hScrollbar.width);
            container.x = -percent*total;
        }else if(isScrollBar && status==EXPAND){
            var total:int = container.height - masker.height;
            var percent:Number = (vScrollbar.y - btn.height - Config.GAP*2)/(vScrollbg.height-vScrollbar.height);
            container.y = -percent*total+btn.height;
        }
    }

    private function onMouseWheel(e:MouseEvent):void{
        if(status==NORMAL && container.width>masker.width){
            var total:int = container.width - masker.width;
            if(e.delta>0){
                hScrollbar.x -= 10;
            }else{
                hScrollbar.x += 10;
            }
            if(hScrollbar.x<Config.GAP*2) hScrollbar.x = Config.GAP*2;
            if(hScrollbar.x>Config.GAP*2+hScrollbg.width-hScrollbar.width) hScrollbar.x = Config.GAP*2+hScrollbg.width-hScrollbar.width;
            var percent:Number = (hScrollbar.x-Config.GAP*2)/(hScrollbg.width-hScrollbar.width);
            container.x = -percent*total;
        }else if(status==EXPAND && container.height>masker.height){
            var total:int = container.height - masker.height;
            if(e.delta>0){
                vScrollbar.y -= 10;
            }else{
                vScrollbar.y += 10;
            }
            if(vScrollbar.y<btn.height+Config.GAP*2) vScrollbar.y = btn.height+Config.GAP*2;
            if(vScrollbar.y>btn.height+Config.GAP*2+vScrollbg.height-vScrollbar.height) vScrollbar.y = btn.height+Config.GAP*2+vScrollbg.height-vScrollbar.height;
            var percent:Number = (vScrollbar.y-btn.height-Config.GAP*2)/(vScrollbg.height-vScrollbar.height);
            container.y = -percent*total+btn.height;
        }
    }

    public function setSourceList(json:String){

        data = JSON.parse(json) as Array;
        for(var i:int=1,n=container.numChildren;i<n;i++){
            var o = container.removeChildAt(1);
            o = null;
        }

        for(var i:int=0; i<data.length; i++){
            var sourcePhoto:SourcePhotoMc = new SourcePhotoMc();
            sourcePhoto.doubleClickEnabled = true;
            sourcePhoto.name = "sourcePhoto_" + i;
            sourcePhoto.container.mouseEnabled = false;
            sourcePhoto.container.doubleClickEnabled = false;
            sourcePhoto.id = data[i].id;
            sourcePhoto.small = data[i].small;
            sourcePhoto.big = data[i].big;
            var loader:Loader = new Loader();
            loader.load(new URLRequest(data[i].small));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded(sourcePhoto));
            container.addChild(sourcePhoto);
        }

        change(status);
    }

    public function getSources():Array{
        var arr:Array = [];
        for(var i:int=1;i<container.numChildren;i++){
            var item = container.getChildAt(i);
            var o = {id:item.id, small:item.small, big:item.big};
            arr.push(o);
        }
        return arr;
    }

    private function onResize(e:Event):void{
        change(status);
    }

    private function onMouseUp(e:MouseEvent):void{
        hScrollbar.stopDrag();
        vScrollbar.stopDrag();
        removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        isScrollBar = false;
    }

    private function onClick(e:MouseEvent):void{
        if(e.target==sourcePhotoBtn){
            var sources:Array = getSources();
            ServiceManager.showSource(JSON.stringify(sources));
        }
        if(e.target.parent==btn){
            if(e.target==btn.expandMc){
                if((status==NORMAL && container.width>masker.width) || status==EXPAND){
                    status = (status==NORMAL)? status=EXPAND : status=NORMAL;
                    btn.expandMc.status_mc.gotoAndStop(status);
                    change(status);
                }
                btn.minimalMc.x = 100;
                btn.minimalMc.status_mc.gotoAndStop('expand');
            }else if(e.target==btn.minimalMc){
                if(status==MINIMAL){
                    btn.expandMc.visible = true;
                    btn.minimalMc.x = 100;
                    btn.minimalMc.status_mc.gotoAndStop('expand');
                    btn.expandMc.status_mc.gotoAndStop('normal');
                    change(NORMAL);
                }else{
                    btn.expandMc.visible = false;
                    btn.minimalMc.x = 0;
                    btn.minimalMc.status_mc.gotoAndStop('normal');
                    change(MINIMAL);
                }
            }
        }

        if(e.target.parent.name.indexOf('sourcePhoto')>=0 && e.target.name=='btn'){
            container.removeChild(e.target.parent);
            container.x = 0;
            container.y = btn.height;
            container.graphics.clear();
            if(status==NORMAL){
                for(var i:int=1; i<container.numChildren; i++){
                    var item = container.getChildAt(i);
                    item.x = Config.GAP*2 + i * (item.width + Config.GAP*2);
                    item.y = Config.GAP*2;
                }

                var w:int = (container.width>masker.width) ? container.width+Config.GAP*4 : stage.stageWidth-Config.ACCORDION_WIDTH;
                drawRect(container, Config.WHITE, w, 240);
                drawRoundRect(hScrollbar, Config.GRAY_DARK, masker.width * (masker.width/container.width), 5);

                if(container.width>masker.width){
                    hScrollbg.visible = hScrollbar.visible = true;
                }else{
                    hScrollbg.visible = hScrollbar.visible = false;
                }

            }else if(status==EXPAND){
                var w:int = stage.stageWidth-Config.ACCORDION_WIDTH;
                var n:int = Math.floor(w/(sourcePhotoBtn.width+Config.GAP*2));

                for(var i:int=1; i<container.numChildren; i++){
                    var item = container.getChildAt(i);
                    item.x = Config.GAP*2 + i%n * (item.width + Config.GAP*2);
                    item.y = Config.GAP*2 + Math.floor(i/n) * (item.height + Config.GAP*2);
                }

                drawRect(container, Config.WHITE, stage.stageWidth-Config.ACCORDION_WIDTH, container.height+Config.GAP*4);
                drawRoundRect(vScrollbar, Config.GRAY_DARK, 5, masker.height * (masker.height/container.height));

                if(container.height>masker.height){
                    vScrollbg.visible = vScrollbar.visible = true;
                }else{
                    vScrollbg.visible = vScrollbar.visible = false;
                }

            }
        }
    }

    private function onLoaded(sourcePhoto:SourcePhotoMc):Function{
        return function(e:Event){
            var bitmap:Bitmap = e.target.content as Bitmap;
            bitmap.width = 160;
            bitmap.height = 220;
            bitmap.smoothing = true;
            sourcePhoto.container.addChild(bitmap);
        }
    }

    private function onDoubleClick(e:MouseEvent):void{
        if(e.target.name.indexOf('sourcePhoto')>=0){
            var i:int = int(e.target.name.split('_')[1]);
            PopupManager.showBig(data[i].big);
        }
    }

    private function drawRect(sp:Sprite, color:uint, w:int, h:int, isBorder:Boolean=false):void{
        sp.graphics.clear();
        if(isBorder){
            sp.graphics.lineStyle(1, Config.GRAY);
        }
        sp.graphics.beginFill(color);
        sp.graphics.drawRect(0, 0, w, h);
        sp.graphics.endFill();
    }

    private function drawRoundRect(sp:Sprite, color:uint, w:int, h:int):void{
        sp.graphics.clear();
        sp.graphics.beginFill(color);
        sp.graphics.drawRoundRect(0, 0, w, h, 5, 5);
        sp.graphics.endFill();
    }

}
}
