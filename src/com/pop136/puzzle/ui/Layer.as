package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.CanvasEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.OperationEvent;
import com.pop136.puzzle.manager.DragManager;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.net.URLRequest;

import ui.DotMc;

public class Layer extends Sprite{

    public var masker:Sprite;
    public var container:Sprite;

    private var tlDot:DotMc;
    private var tmDot:DotMc;
    private var trDot:DotMc;
    private var mlDot:DotMc;
    private var mrDot:DotMc;
    private var blDot:DotMc;
    private var bmDot:DotMc;
    private var brDot:DotMc;

    private var dot:DotMc;

    private var _selected:Boolean;


    public var id:String;
    public var small:String;
    public var big:String;
    public var brand:String;
    public var description:String;
    public var link:String;
    public var linkType:String;

    public var layerDragable:Boolean = true;

    public var rx:int = 0;
    public var ry:int = 0;

    public var data;

    private var messager:Messager = Messager.getInstance();
    private var thisPoint = new Point();
    private var containerPoint = new Point();
    private var dotPoint = new Point();

    public function Layer(data) {

        this.data = data;

        this.x = data.x;
        this.y = data.y;

        container = new Sprite();
        addChild(container);

        masker = new Sprite();
        addChild(masker);

        if(data.photo && data.photo.big){
            this.id = data.photo.id;
            this.small = data.photo.small;
            this.big = data.photo.big;
            this.brand = data.photo.brand;
            this.description = data.photo.description;
            this.link = data.photo.link;
            this.linkType = data.photo.linkType;
            this.rx = data.photo.rotationX;
            this.ry = data.photo.rotationY;
            var self = this;
            var loader:Loader = new Loader();
            loader.load(new URLRequest(data.photo.big));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event) {
                var bitmap:Bitmap = e.target.content as Bitmap;
                bitmap.x = -bitmap.width/2;
                bitmap.y = -bitmap.height/2;
                container.addChild(bitmap);

                if(rx==-180){
//                    bitmap.rotationX = -180;
//                    bitmap.y = bitmap.height/2;
                    var matrix:Matrix = new Matrix();
                    matrix.d = -1;
                    matrix.ty = bitmap.bitmapData.height;
                    bitmap.bitmapData.draw(bitmap.bitmapData.clone(), matrix);
                }
                if(ry==-180){
//                    bitmap.rotationY = -180;
//                    bitmap.x = bitmap.width/2;
                    var matrix:Matrix = new Matrix();
                    matrix.a = -1;
                    matrix.tx = bitmap.bitmapData.width;
                    bitmap.bitmapData.draw(bitmap.bitmapData.clone(), matrix);
                }

//                self.graphics.lineStyle(5, Config.RED);
                self.graphics.beginFill(0xffffff, 0);
                self.graphics.drawRect(0, 0, data.width, data.height);
                self.graphics.endFill();
                masker.graphics.beginFill(0xffffff);
                masker.graphics.drawRect(0, 0, data.width, data.height);
                masker.graphics.endFill();

                container.x = data.photo.x;
                container.y = data.photo.y;

//                selected = true;
            });
            container.scaleX = container.scaleY = data.photo.scale;
            container.rotation = data.photo.rotation;
        }else{
            container.x = data.width/2;
            container.y = data.height/2;
        }

        container.mask = masker;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):void{

        trace('layer onAddedToStage:', this.x, this.y);

        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        container.addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent) {
            DragManager.setMouse(DragManager.DRAG, e.stageX, e.stageY);
        });
    }

    private function onMouseOver(e:MouseEvent):void{
        if(e.target==container){
            DragManager.setMouse(DragManager.DRAG, e.stageX, e.stageY)
        }
        if(e.target is DotMc){
            var rotation = 0;
            if(e.target==tlDot || e.target==brDot) {
                rotation = 45;
            }else if(e.target==trDot || e.target==blDot){
                rotation = -45;
            }else if(e.target==tmDot || e.target==bmDot){
                rotation = 90;
            }else if(e.target==mlDot || e.target==mrDot){
                rotation = 0;
            }
            DragManager.setMouse(DragManager.BORDER, e.stageX, e.stageY, rotation)
        }
    }

    private function onMouseDown(e:MouseEvent):void{
        thisPoint.x = this.x;
        thisPoint.y = this.y;
        containerPoint.x = container.x;
        containerPoint.y = container.y;
        if(layerDragable){
            this.startDrag();
        }
        if(e.target==container && !layerDragable){
            container.startDrag();
        }
        if(e.target is DotMc){
            dot = e.target as DotMc;
            var rectangle:Rectangle = null;
            if(dot==tmDot){
                rectangle = new Rectangle(tmDot.x, -500, 0, 2000);
            }else if(dot==mrDot){
                rectangle = new Rectangle(-500, mrDot.y, 2000, 0);
            }else if(dot==bmDot){
                rectangle = new Rectangle(bmDot.x, -500, 0, 2000);
            }else if(dot==mlDot){
                rectangle = new Rectangle(-1000, mlDot.y, 2000, 0);
            }
            dot.startDrag(false, rectangle);
            dotPoint.x = dot.x;
            dotPoint.y = dot.y;
        }
        trace('layer onMouseDown:', this.x, this.y);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    private function onMouseMove(e:MouseEvent):void{
        if(e.target==container){
            DragManager.setMouse(null, e.stageX, e.stageY);
        }
        if(dot){
            DragManager.setMouse(null, e.stageX, e.stageY);
            resize(e);
        }
    }

    private function onMouseUp(e:MouseEvent):void{
        trace('Layer onMouseUp');
        this.stopDrag();
        container.stopDrag();

        var thisMoved = Math.abs(this.x - thisPoint.x) > 1 || Math.abs(this.y - thisPoint.y) > 1;
        var containerMoved = Math.abs(container.x - containerPoint.x) > 1 || Math.abs(container.y - containerPoint.y) > 1;
        var dotMoved = false;

        if(dot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.x += tlDot.x;
            this.y += tlDot.y;
            container.x -= tlDot.x;
            container.y -= tlDot.y;
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(0xffffff, 0);
            this.graphics.drawRect(0, 0, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(0, 0, w, h);
            masker.graphics.endFill();
            tlDot.x = mlDot.x = blDot.x = 0;
            tmDot.x = bmDot.x = w/2;
            trDot.x = mrDot.x = brDot.x = w;
            tlDot.y = tmDot.y = trDot.y = 0;
            mlDot.y = mrDot.y = h/2;
            blDot.y = bmDot.y = brDot.y = h;
            dot.stopDrag();
            dotMoved = Math.abs(dot.x - dotPoint.x) > 1 || Math.abs(dot.y - dotPoint.y) > 1;
            dot = null;
        }
        removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        if(thisMoved || containerMoved || dotMoved){
            messager.dispatchEvent(new OperationEvent(OperationEvent.SAVE_OPERATION));
        }
    }

    private function onMouseOut(e:MouseEvent):void{
        if(e.target==container){
            DragManager.setMouse(DragManager.NATIVE);
        }
        if(e.target is DotMc){
            DragManager.setMouse(DragManager.NATIVE);
        }
    }

    private function resize(e:MouseEvent):void{
        if(dot==tlDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, w, h);
//            this.graphics.drawRect(0, 0, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            masker.graphics.endFill();
            tmDot.x = bmDot.x = w/2 + tlDot.x;
            tmDot.y = tlDot.y;
            trDot.y = tlDot.y;
            mlDot.x = tlDot.x;
            mlDot.y = mrDot.y = tlDot.y + h/2;
            blDot.x = tlDot.x;
        }else if(dot==tmDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tmDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tmDot.y, w, h);
            masker.graphics.endFill();
            tlDot.y = trDot.y = tmDot.y;
            mlDot.y = mrDot.y = tlDot.y + h/2;
        }else if(dot==trDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            masker.graphics.endFill();
            tmDot.x = bmDot.x = w/2 + tlDot.x;
            tmDot.y = trDot.y;
            tlDot.y = trDot.y;
            mrDot.x = trDot.x;
            mlDot.y = mrDot.y = trDot.y + h/2;
            brDot.x = trDot.x;
        }else if(dot==mlDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            masker.graphics.endFill();
            tlDot.x = blDot.x = mlDot.x;
            tmDot.x = bmDot.x = tlDot.x + w/2;
        }else if(dot==mrDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            masker.graphics.endFill();
            trDot.x = brDot.x = mrDot.x;
            tmDot.x = bmDot.x = tlDot.x + w/2;
        }else if(dot==blDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            masker.graphics.endFill();
            tmDot.x = bmDot.x = w/2 + tlDot.x;
            bmDot.y = blDot.y;
            brDot.y = blDot.y;
            mlDot.x = blDot.x;
            mlDot.y = mrDot.y = tlDot.y + h/2;
            tlDot.x = blDot.x;
        }else if(dot==bmDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tmDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tmDot.y, w, h);
            masker.graphics.endFill();
            blDot.y = brDot.y = bmDot.y;
            mlDot.y = mrDot.y = tlDot.y + h/2;
        }else if(dot==brDot){
            var w:int = Math.abs(tlDot.x - brDot.x);
            var h:int = Math.abs(tlDot.y - brDot.y);
            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(Config.GRAY_LIGHT, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            this.graphics.endFill();
            masker.graphics.clear();
            masker.graphics.beginFill(0xffffff);
            masker.graphics.drawRect(tlDot.x, tlDot.y, w, h);
            masker.graphics.endFill();
            tmDot.x = bmDot.x = w/2 + tlDot.x;
            bmDot.y = brDot.y;
            blDot.y = brDot.y;
            mrDot.x = brDot.x;
            mlDot.y = mrDot.y = trDot.y + h/2;
            trDot.x = brDot.x;
        }
    }

    public function set selected(val:Boolean):void{
        if(val){
            if(!tlDot){
                tlDot = new DotMc();
                addChild(tlDot);
            }

            if(!tmDot){
                tmDot = new DotMc();
                tmDot.x = data.width/2;
                addChild(tmDot);
            }

            if(!trDot){
                trDot = new DotMc();
                trDot.x = data.width;
                addChild(trDot);
            }

            if(!mlDot){
                mlDot = new DotMc();
                mlDot.y = data.height/2;
                addChild(mlDot);
            }

            if(!mrDot){
                mrDot = new DotMc();
                mrDot.x = data.width;
                mrDot.y = data.height/2;
                addChild(mrDot);
            }

            if(!blDot){
                blDot = new DotMc();
                blDot.y = data.height;
                addChild(blDot);
            }

            if(!bmDot){
                bmDot = new DotMc();
                bmDot.x = data.width/2;
                bmDot.y = data.height;
                addChild(bmDot);
            }

            if(!brDot){
                brDot = new DotMc();
                brDot.x = data.width;
                brDot.y = data.height;
                addChild(brDot);
            }

            tlDot.visible = tmDot.visible = trDot.visible = mlDot.visible = mrDot.visible = blDot.visible = bmDot.visible = brDot.visible = true;

            this.graphics.clear();
            this.graphics.lineStyle(5, Config.RED);
            this.graphics.beginFill(0xffffff, 0);
            this.graphics.drawRect(tlDot.x, tlDot.y, masker.width, masker.height);
            this.graphics.endFill();

            _selected = true;
        }else{
            if(tlDot && tmDot && trDot && mlDot && mrDot && blDot && bmDot && brDot){
                tlDot.visible = tmDot.visible = trDot.visible = mlDot.visible = mrDot.visible = blDot.visible = bmDot.visible = brDot.visible = false;
                this.graphics.clear();
//                this.graphics.lineStyle(5, Config.GRAY);
                this.graphics.beginFill(0xffffff, 0);
                this.graphics.drawRect(tlDot.x, tlDot.y, masker.width, masker.height);
                this.graphics.endFill();
            }

            _selected = false;
        }
    }

    public function get selected():Boolean{
        return _selected;
    }

    private function onMouseWheel(e:MouseEvent):void{

        var current:int = container.scaleX * 100;

        if(e.delta>0){
            if(current<200)
                container.scaleX = container.scaleY += 0.1;
        }else{
            if(current>0)
                container.scaleX = container.scaleY -= 0.1;
        }

        container.scaleX = container.scaleY = Number(container.scaleX.toFixed(2));
        dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_SCALE, container.scaleX));
    }

    public function dispose():void{

        this.selected = false;

        this.graphics.clear();

        masker.graphics.clear();

        container.removeChildren();

        removeChildren();
        masker = container = data = dot = tlDot = tmDot = trDot = mlDot = mrDot = blDot = bmDot = brDot = null;

    }

}
}
