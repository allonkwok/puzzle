package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.CanvasEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.OperationEvent;
import com.pop136.puzzle.manager.DragManager;
import com.pop136.puzzle.manager.PopupManager;
import com.pop136.puzzle.manager.ServiceManager;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.setTimeout;

import ui.HolderMc;

public class Grid extends Sprite {

    private var _selected:Boolean;

    public var masker:Sprite;
    public var container:Sprite;

    private var fr:FileReference;
    private var fa:Array;
    private var loader:Loader;

    public var top:Array = [];
    public var right:Array = [];
    public var bottom:Array = [];
    public var left:Array = [];

    public var topMc:HolderMc;
    public var rightMc:HolderMc;
    public var bottomMc:HolderMc;
    public var leftMc:HolderMc;

    public var id:String='0';
    public var small:String='';
    public var big:String='';
    public var brand:String='';
    public var description:String='';
    public var link:String='';
    public var linkType:String='0';
    public var isLocal:Boolean;

    public var rx:int = 0;
    public var ry:int = 0;

    public var used:Boolean;

    public var txt:TextField;

    public var data;

    private var dragging:Boolean = false;
    private var isNew:Boolean = false;  //新的本地图片，而非交换来，保存图片用

    private var messager:Messager = Messager.getInstance();

    private var oldPoint = new Point();


    public function Grid(data:Object) {

        super();

        this.data =data;

        this.x = data.x;
        this.y = data.y;

        this.graphics.lineStyle(1, Config.GRAY);
        this.graphics.beginFill(0xffffff);
        this.graphics.drawRect(0, 0, data.width, data.height);
        this.graphics.endFill();
//        this.mouseEnabled = false;
//        this.mouseChildren = true;

        container = new Sprite();
        container.name = 'container';
        container.mouseChildren = false;
        addChild(container);

        txt = new TextField();
        txt.background = true;
        txt.borderColor = 0xff9900;
        txt.multiline = false;
        txt.x = txt.y = 10;
        txt.width = 150;
        txt.height = 50;
        txt.border = true;
        txt.defaultTextFormat = new TextFormat(null, 36, 0xff9900, null, null, null, null, null, 'center');
        txt.visible = false;
        txt.text = '';
        txt.mouseEnabled = false;
        addChild(txt);

        if(data.photo && data.photo.big){
            this.id = data.photo.id;
            this.small = data.photo.small;
            this.big = data.photo.big;
            this.brand = data.photo.brand;
            this.description = data.photo.description;
            this.link = data.photo.link;
            this.linkType = data.photo.linkType;
            this.isLocal = false;
            this.rx = data.photo.rotationX;
            this.ry = data.photo.rotationY;
            var ldr:Loader = new Loader();
            ldr.load(new URLRequest(data.photo.big));
            ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event) {
                var bitmap:Bitmap = e.target.content as Bitmap;
                bitmap.x = -bitmap.width/2;
                bitmap.y = -bitmap.height/2;
                container.addChild(bitmap);

                if(rx==-180){
//                    bitmap.rotationX = data.photo.rotationX;
//                    bitmap.y = bitmap.height/2;
                    var matrix:Matrix = new Matrix();
                    matrix.d = -1;
                    matrix.ty = bitmap.bitmapData.height;
                    bitmap.bitmapData.draw(bitmap.bitmapData.clone(), matrix);
                }
                if(ry==-180){
//                    bitmap.rotationY = data.photo.rotationY;
//                    bitmap.x = bitmap.width/2;
                    var matrix:Matrix = new Matrix();
                    matrix.a = -1;
                    matrix.tx = bitmap.bitmapData.width;
                    bitmap.bitmapData.draw(bitmap.bitmapData.clone(), matrix);
                }
            });
            container.x = data.photo.x;
            container.y = data.photo.y;
            container.scaleX = container.scaleY = data.photo.scale;
            container.rotation = data.photo.rotation;
        }else{
            container.x = data.width/2;
            container.y = data.height/2;
        }

        masker = new Sprite();
        masker.graphics.beginFill(0xffffff);
        masker.graphics.drawRect(0, 0, data.width, data.height);
        masker.graphics.endFill();
        masker.mouseEnabled = false;
        addChild(masker);

        container.mask = masker;


        setBorder();

        doubleClickEnabled = container.doubleClickEnabled = true;
        addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        fr = new FileReference();
        fr.addEventListener(Event.SELECT, onSelect);
        fr.addEventListener(ProgressEvent.PROGRESS, onProgress);
        fr.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
        fa = [new FileFilter("Images", "*.jpg;*.gif;*.png")];

        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
    }

    private function onProgress(e:ProgressEvent):void{
        var percent:Number = e.bytesLoaded/e.bytesTotal;
        txt.text = Math.round(percent*100)+'%';
    }

    private function onUploadCompleteData(e:DataEvent):void{
        trace(e.data.toString());
        var o = JSON.parse(e.data.toString());
        if(o.code==1){
            this.id = o.data.id;
            this.small = o.data.photo;
            this.big = o.data.photo;
            txt.visible = false;
        }else{
//            PopupManager.showSaveDialog("图片上传失败，请重新上传！");
            txt.visible = true;
            txt.text = "上传失败";
        }
    }

    public function drawFlag(color:uint):void{
//        this.graphics.clear();
//        this.graphics.lineStyle(1, Config.GRAY);
//        this.graphics.beginFill(color);
//        this.graphics.drawRect(0, 0, data.width, data.height);
//        this.graphics.endFill();
    }

    public function loadContent(thumb:MovieClip):void{
        reset();
        this.id = thumb.id;
        this.small = thumb.small;
        this.big = thumb.big;
        this.brand = thumb.brand;
        this.description = thumb.description;
        this.link = thumb.link;
        this.linkType = thumb.linkType;
        if(thumb.isLocal!==null){
            this.isLocal = thumb.isLocal;
        }else{
            this.isLocal = false;
        }
        loader.load(new URLRequest(thumb.big));
    }

    private function onAddedToStage(e:Event):void{
        trace('Grid onAddedToStage:', this.name);
        container.addEventListener(MouseEvent.MOUSE_DOWN, onContainerDown);
        container.addEventListener(MouseEvent.MOUSE_UP, onContainerUp);
        container.stage.addEventListener(MouseEvent.MOUSE_UP, onContainerUp);
    }

    private function onContainerDown(e:MouseEvent):void{
        trace('onContainerDown:', this.name, e.target.name, e.currentTarget.name);
        container.startDrag();
        dragging = true;
        oldPoint.x = container.x;
        oldPoint.y = container.y;
    }

    private function onContainerUp(e:MouseEvent):void{
        trace('onContainerUp:', this.name, e.target.name, e.currentTarget.name);
        if(container)
            container.stopDrag();
        dragging = false;
        if(e.currentTarget.name=='container' && (container.x!=oldPoint.x || container.y!=oldPoint.y)){
            trace('OperationEvent.SAVE_OPERATION');
            messager.dispatchEvent(new OperationEvent(OperationEvent.SAVE_OPERATION));
        }
    }

    private function onMouseOver(e:MouseEvent):void{
        if(e.target==container){
            DragManager.setMouse(DragManager.DRAG, e.stageX, e.stageY)
        }
        if(e.target==topMc || e.target==rightMc || e.target==bottomMc || e.target==leftMc){
            var rotation = (e.target==topMc || e.target==bottomMc) ? 90 : 0;
            DragManager.setMouse(DragManager.BORDER, e.stageX, e.stageY, rotation);
        }
    }
    private function onMouseMove(e:MouseEvent):void{
        if(e.target==container){
            DragManager.setMouse(null, e.stageX, e.stageY);
        }
        if(e.target==topMc || e.target==rightMc || e.target==bottomMc || e.target==leftMc){
            DragManager.setMouse(null, e.stageX, e.stageY);
        }
    }
    private function onMouseOut(e:MouseEvent):void{
        if(e.target==container){
            DragManager.setMouse(DragManager.NATIVE);
        }
        if(e.target==topMc || e.target==rightMc || e.target==bottomMc || e.target==leftMc){
            DragManager.setMouse(DragManager.NATIVE);
        }
        if(dragging){
            if(container)
                container.stopDrag();
            DragManager.showThumbByGrid();
        }
    }

    private function setBorder():void{
        if(!topMc){
            topMc = new HolderMc();
            topMc.name = 'topMc';
            addChild(topMc);
        }
        topMc.x = 0;
        topMc.y = 0;
        topMc.width = data.width;
        topMc.height = 10;

        if(!rightMc){
            rightMc = new HolderMc();
            rightMc.name = 'rightMc';
            addChild(rightMc);
        }
        rightMc.x = data.width - 10;
        rightMc.y = 0;
        rightMc.width = 10;
        rightMc.height = data.height;

        if(!bottomMc){
            bottomMc = new HolderMc();
            bottomMc.name = 'bottomMc';
            addChild(bottomMc);
        }
        bottomMc.x = 0;
        bottomMc.y = data.height - 10;
        bottomMc.width = data.width;
        bottomMc.height = 10;

        if(!leftMc){
            leftMc = new HolderMc();
            leftMc.name = 'leftMc';
            addChild(leftMc);
        }
        leftMc.x = 0;
        leftMc.y = 0;
        leftMc.width = 10;
        leftMc.height = data.height;

        topMc.alpha = rightMc.alpha = bottomMc.alpha = leftMc.alpha = 0;
    }

    public function resize(side:String, p:Point){
        if(side==Canvas.TOP){
            this.y += p.y;
            data.y = this.y;
            data.height -= p.y;
            leftMc.height = rightMc.height = data.height;
            bottomMc.y = data.height - 10;
//            txt.text = 'y:'+this.y+'\r'+'height:'+masker.height+'\r';
        }else if(side==Canvas.BOTTOM){
            bottomMc.y = p.y-Config.GRID_GAP-10;
            leftMc.height = rightMc.height = bottomMc.y-topMc.y+10;
            data.height = leftMc.height;
//            txt.text = 'y:'+this.y+'\r'+'height:'+masker.height+'\r';
        }else if(side==Canvas.LEFT){
            this.x += p.x;
            data.x = this.x;
            data.width -= p.x;
            topMc.width = bottomMc.width = data.width;
            rightMc.x = data.width - 10;
//            txt.text = 'x:'+this.x+'\r'+'width:'+masker.width+'\r';
        }else if(side==Canvas.RIGHT){
            rightMc.x = p.x-Config.GRID_GAP-10;
            topMc.width = bottomMc.width = rightMc.x-leftMc.x+10;
            data.width = topMc.width;
//            txt.text = 'x:'+this.x+'\r'+'width:'+masker.width+'\r';
        }
        this.graphics.clear();
        this.graphics.lineStyle(1, Config.GRAY);
        this.graphics.beginFill(0xffffff);
        this.graphics.drawRect(0, 0, data.width, data.height);
        this.graphics.endFill();
        masker.graphics.clear();
        masker.graphics.beginFill(0xffffff);
        masker.graphics.drawRect(0, 0, data.width, data.height);
        masker.graphics.endFill();
    }

    public function redraw(ww:Number, hh:Number, direction:String):void{
        if(direction==Canvas.RIGHT){//向右扩展
            data.width += ww;
        }else if(direction==Canvas.LEFT){//向左位移，向右扩展
            this.x -= ww;
            data.x -= ww;
            data.width += ww;
        }else if(direction==Canvas.BOTTOM){//向下扩展
            data.height += hh;
        }else if(direction==Canvas.TOP){//向上位移，向下扩展
            this.y -= hh;
            data.y -= hh;
            data.height += hh;
        }
        this.graphics.clear();
        this.graphics.lineStyle(1, Config.GRAY);
        this.graphics.beginFill(0xffffff);
        this.graphics.drawRect(0, 0, data.width, data.height);
        this.graphics.endFill();
        masker.graphics.clear();
        masker.graphics.beginFill(0xffffff);
        masker.graphics.drawRect(0, 0, data.width, data.height);
        masker.graphics.endFill();
        container.x = data.width/2;
        container.y = data.height/2;
        setBorder();
    }

    public function select():void{
        fr.browse(fa);
    }

    public function reset():void{
        container.removeChildren();
        container.x = masker.width/2;
        container.y = masker.height/2;
        container.rotation = 0;
        container.scaleX = container.scaleY = 1;
        id = '0';
        small = '';
        big = '';
        brand = '';
        description = '';
        link = '';
        linkType = '0';
        isLocal = false;
        rx = 0;
        ry = 0;
    }

    public function set selected(val:Boolean):void{
        if(val){
            this.graphics.clear();
            this.graphics.lineStyle(4, Config.RED);
            this.graphics.beginFill(0xffffff);
            this.graphics.drawRect(0, 0, data.width, data.height);
            this.graphics.endFill();
            _selected = true;
        }else{
            this.graphics.clear();
            this.graphics.lineStyle(1, Config.GRAY);
            this.graphics.beginFill(0xffffff);
            this.graphics.drawRect(0, 0, data.width, data.height);
            this.graphics.endFill();
            _selected = false;
        }
    }

    public function get selected():Boolean{
        return _selected;
    }

    private function onMouseWheel(e:MouseEvent):void{
        if(_selected){
            var current:int = container.scaleX * 100;

            if(e.delta>0){
                if(current<400)
                    container.scaleX = container.scaleY += 0.1;
            }else{
                if(current>10)
                    container.scaleX = container.scaleY -= 0.1;
            }

            container.scaleX = container.scaleY = Number(container.scaleX.toFixed(2));
            dispatchEvent(new CanvasEvent(CanvasEvent.GRID_SCALE, container.scaleX));
        }
    }

    private function onSelect(e:Event):void{
        fr.addEventListener(Event.COMPLETE, onComplete);
        fr.load();
        isLocal = true;
        isNew = true;
        id = '0';
        small = '';
        big = '';
    }

    private function onComplete(e:Event):void{
        fr.removeEventListener(Event.COMPLETE, onComplete);
        loader.loadBytes(e.target.data);
        setTimeout(function () {
            messager.dispatchEvent(new OperationEvent(OperationEvent.SAVE_OPERATION));
        }, 1000);
    }

    private function onLoaderComplete(e:Event):void{
        var bmp:Bitmap = e.target.content as Bitmap;
        bmp.x = -bmp.width/2;
        bmp.y = -bmp.height/2;
        bmp.smoothing = true;
        container.removeChildren();
        container.x = masker.width/2;
        container.y = masker.height/2;
        container.rotation = 0;
        container.scaleX = container.scaleY = 1;
        container.addChild(bmp);
        txt.visible = false;
        if(isLocal && isNew){
            isNew = false;
            txt.visible = true;
            ServiceManager.savePhoto(fr, 'grid');
        }
    }

    private function onDoubleClick(e:MouseEvent):void{
        fr.browse(fa);
    }

    public function dispose(){
        this.selected = false;
        top.length = right.length = bottom.length = left.length = 0;
        top = null;
        right = null;
        bottom = null;
        left = null;
        this.graphics.clear();
        masker.graphics.clear();
        masker = null;
        container.removeChildren();
        container = null;
        fr = null;
        fa.length = 0; fa=null;
        if(loader){
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
            loader.removeChildren();
            loader = null;
        }
    }
}
}
